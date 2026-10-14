"""Test an independent consumer against the actual archive, or a public registry version.
All generated files remain below this project's _build directory.
"""
import argparse, json, pathlib, re, subprocess, sys, tempfile, zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
MODULE = 'Magic486/moonnetlink'

def run(*args, cwd=ROOT):
    result = subprocess.run(list(map(str, args)), cwd=cwd, check=True, capture_output=True, text=True, encoding='utf8', timeout=180)
    print(result.stdout, end='')
    return result.stdout

def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding='utf8')

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--registry-version')
    args = parser.parse_args()
    version = args.registry_version or re.search(r'^version\s*=\s*"([^"]+)"', (ROOT/'moon.mod').read_text(), re.M)[1]
    base = ROOT/'_build/consumer-checks'
    base.mkdir(parents=True, exist_ok=True)
    work = pathlib.Path(tempfile.mkdtemp(prefix='consumer-', dir=base))
    if not args.registry_version:
        run('moon', 'package')
        archive = ROOT/'_build/publish'/f'Magic486-moonnetlink-{version}.zip'
        with zipfile.ZipFile(archive) as package:
            names = package.namelist()
            assert all(not pathlib.PurePosixPath(name).is_absolute() and '..' not in pathlib.PurePosixPath(name).parts for name in names)
            assert 'native/bridge.c' in names, 'archive omitted the native bridge'
            assert not any(part in {'release-local', 'research', 'demo-output', '.git', 'credentials.json'} for name in names for part in pathlib.PurePosixPath(name).parts)
            package.extractall(work/'library')
        write(work/'moon.work', 'members = ["library", "consumer"]\n')
    consumer = work/'consumer'
    write(consumer/'moon.mod', f'name = "acceptance-smoke/consumer"\nversion = "0.0.1"\nimport {{ "{MODULE}@{version}" }}\n')
    write(consumer/'moon.pkg', 'import {\n'+''.join(f'  "{MODULE}/{name}",\n' for name in ['wire', 'route', 'genl', 'journal', 'replay'])+'} for "test"\n')
    write(consumer/'consumer_test.mbt', r'''///|
test "independent consumer exercises protocol multipath discovery and replay APIs" {
  let bytes = b"\x20\x00\x00\x00\x10\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x07\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00"
  assert_eq(@wire.decode(bytes).length(), 1)
  assert_eq(@route.decode_next_hops(b"\x08\x00\x00\x00\x07\x00\x00\x00", 2)[0].index, 7)
  let request = @genl.family_request("nlctrl", 123U)
  assert_eq(request.header.sequence, 123U)
  assert_eq(@genl.decode(request.payload).command, 3)
  let session = @replay.Session::new()
  session.apply(@journal.Datagram(bytes, @wire.Little))
  assert_eq(session.summary().state.links[0].index, 7)
  session.apply(@journal.Loss("explicit consumer loss"))
  assert_eq(session.summary().losses, 1)
  assert_true(session.summary().state.stale)
}
''')
    write(consumer/'probe/moon.pkg', f'import {{ "{MODULE}/native", "{MODULE}/route" }}\nsupported_targets = "native"\npkgtype(kind: "executable")\n')
    write(consumer/'probe/main.mbt', '''///|
fn main raise {
  let route = @native.Socket::open()
  defer route.close()
  let links = route.dump(@route.Links)
  let generic = @native.Socket::open(protocol=@native.Generic)
  defer generic.close()
  let controller = generic.family("nlctrl")
  let result : Json = {"link_events": links.events.length(), "controller": controller.family.name}
  println(result.stringify())
}
''')
    if args.registry_version:
        run('moon', '-C', consumer, 'update')
    for target in ['wasm-gc', 'js']:
        run('moon', '-C', consumer, 'test', '--target', target, '--deny-warn')
    report = {'version': version, 'source': 'registry' if args.registry_version else 'packaged archive in isolated workspace', 'portable_consumer_tests': True}
    if sys.platform.startswith('linux'):
        run('moon', '-C', consumer, 'test', '--target', 'native', '--deny-warn')
        report['linux_native'] = json.loads(run('moon', '-C', consumer, 'run', 'probe', '--target', 'native'))
        assert report['linux_native']['controller'] == 'nlctrl'
    write(ROOT/'demo-output'/('consumer-registry.json' if args.registry_version else 'consumer-archive.json'), json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))

if __name__ == '__main__':
    main()
