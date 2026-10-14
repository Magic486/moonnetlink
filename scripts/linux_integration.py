"""Independent iproute2 oracle + CLI contracts + real events in an isolated netns.
Run from project root on Linux: python3 scripts/linux_integration.py
No package installs, network access, or host network configuration changes.
"""
import argparse, ipaddress, json, os, pathlib, subprocess, sys, time
ROOT=pathlib.Path(__file__).resolve().parents[1]
OUT=ROOT/'demo-output'
OUT.mkdir(exist_ok=True)
BINARY=ROOT/'_build/native/debug/build/cmd/moonnet/moonnet.exe'
def run(*args,check=True):
    return subprocess.run([str(x) for x in args],cwd=ROOT,capture_output=True,text=True,check=check,timeout=70)
def ip(*args):return json.loads(run('ip','-j',*args).stdout)
def save(name,value): (OUT/name).write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')
def normalize(value):return str(ipaddress.ip_address(value)) if value else ''
def compare(label,actual,expected):
    missing=expected-actual; extra=actual-expected
    assert not missing and not extra, f'{label}: missing={sorted(missing)!r}, extra={sorted(extra)!r}'
    return {'category':label,'matched':len(expected)}
def snapshot_test():
    journal=OUT/'live-snapshot.jsonl'
    result=json.loads(run(BINARY,'snapshot','--record',journal).stdout)
    save('live-snapshot.json',result)
    assert result['complete_by_kind'] is True and result['atomic_across_kinds'] is False
    links=ip('link','show'); addrs=ip('address','show')
    names={x['ifname']:x['ifindex'] for x in links}
    checks=[]
    checks.append(compare('link (index,name,mtu,hardware address)',
        {(x['index'],x.get('name'),x.get('mtu'),x.get('address','')) for x in result['links']},
        {(x['ifindex'],x['ifname'],x['mtu'],x.get('address','')) for x in links}))
    checks.append(compare('address (index,family,prefix,local)',
        {(x['index'],x['family'],x['prefix_length'],normalize(x.get('local_address') or x.get('address'))) for x in result['addresses']},
        {(x['ifindex'],2 if a['family']=='inet' else 10,a['prefixlen'],normalize(a['local'])) for x in addrs for a in x['addr_info']}))
    routes=[]
    for flag,family in [('-4',2),('-6',10)]:
        for r in ip(flag,'route','show','table','all'):routes.append((family,r))
    table={'main':254,'local':255,'default':253,'unspec':0}
    def rt(f,r):
        dst=r.get('dst','default')
        network=ipaddress.ip_network(('0.0.0.0/0' if f==2 else '::/0') if dst=='default' else dst,strict=False)
        t=r.get('table',254); t=table.get(t,t)
        return (f,int(t),str(network),normalize(r.get('gateway')),names.get(r.get('dev'),0),r.get('metric',0))
    actual=set()
    for r in result['routes']:
        if r['family'] not in [2,10]:continue
        zero='0.0.0.0' if r['family']==2 else '::'
        net=ipaddress.ip_network(f"{r.get('destination') or zero}/{r['destination_prefix']}",strict=False)
        actual.add((r['family'],r['table'],str(net),normalize(r.get('gateway')),r.get('output_interface',0),r.get('priority',0)))
    checks.append(compare('route (family,table,prefix,gateway,interface,metric)',actual,{rt(f,r) for f,r in routes}))
    neighbors=[]
    for flag,family in [('-4',2),('-6',10)]:
        for n in ip(flag,'neighbor','show','nud','all'):neighbors.append((family,n))
    checks.append(compare('neighbor (family,interface,IP)',
        {(n['family'],n['index'],normalize(n.get('destination'))) for n in result['neighbors'] if n['family'] in [2,10]},
        {(f,names[n['dev']],normalize(n['dst'])) for f,n in neighbors}))
    oracle={(f,names[n['dev']],normalize(n['dst'])):n.get('lladdr','') for f,n in neighbors}
    nonempty=[n for n in result['neighbors'] if n['family'] in [2,10] and n.get('lladdr')]
    for n in nonempty:assert n['lladdr']==oracle[(n['family'],n['index'],normalize(n.get('destination')))]
    checks.append({'category':'neighbor nonempty hardware address','matched':len(nonempty),
        'empty_kernel_attributes_not_compared':len(result['neighbors'])-len(nonempty),
        'reason':'Absent or zero-length NDA_LLADDR is preserved; hardware-address comparison covers only nonempty kernel attributes. All neighbor identities are compared.'})
    replay=json.loads(run(BINARY,'replay',journal).stdout)['state']
    for key in ['links','addresses','routes','neighbors']:assert replay[key]==result[key],f'replay changed {key}'
    assert not replay['stale']
    save('live-replay.json',replay)
    return checks
def cli_test():
    checks=[]
    for args in [('wat',),('watch','0',str(OUT/'invalid.jsonl')),('watch','999',str(OUT/'invalid.jsonl')),('replay',str(OUT/'absent.jsonl'))]:
        p=run(BINARY,*args,check=False)
        assert p.returncode!=0 and p.stdout=='', (args,p.returncode,p.stdout)
        assert 'error' in json.loads(p.stderr),p.stderr
        checks.append({'arguments':list(args),'exit_code':p.returncode,'error_json':True})
    bad=OUT/'bad-version.jsonl'; bad.write_text('{"version":2,"kind":"loss","reason":"x"}\n')
    p=run(BINARY,'replay',bad,check=False)
    assert p.returncode==1 and 'error' in json.loads(p.stderr)
    demo=json.loads(run(BINARY,'demo').stdout)
    assert demo['source']=='synthetic-demo' and demo['state']['stale']
    return checks+[{'contract':'bad journal version rejected, synthetic loss clearly labelled','passed':True}]

def family_test():
    record=OUT/'controller.jsonl'
    family=json.loads(run(BINARY,'family','nlctrl','--record',record).stdout)['family']
    replay=json.loads(run(BINARY,'family-replay',record).stdout)['family']
    assert family==replay, 'controller record/replay drift'
    assert family['id']==16 and family['name']=='nlctrl'
    assert any(op['id']==3 for op in family['operations'])
    unknown=run(BINARY,'family','mn-no-such-fam',check=False)
    assert unknown.returncode==1 and not unknown.stdout and 'error' in json.loads(unknown.stderr)
    return {'name':family['name'],'id':family['id'],'operation_count':len(family['operations']),'group_count':len(family['groups']),'replay_equal':True,'missing_family_rejected':True}
def namespace_events():
    # This function is launched only within a fresh network namespace.
    assert os.environ.get('MOONNETLINK_ISOLATED')=='1'
    record=OUT/'namespace-events.jsonl'
    process=subprocess.Popen([str(BINARY),'watch','3',str(record)],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
    first=process.stdout.readline()
    assert json.loads(first)['kind']=='ready',first
    try:
        run('ip','link','add','mn-demo0','type','dummy')
        run('ip','link','set','mn-demo0','up')
        run('ip','address','add','192.0.2.7/24','dev','mn-demo0')
        run('ip','-6','address','add','2001:db8::7/64','dev','mn-demo0','nodad')
        run('ip','route','add','198.51.100.0/24','dev','mn-demo0','metric','123')
        run('ip','neighbor','add','192.0.2.8','lladdr','02:00:00:00:00:08','nud','permanent','dev','mn-demo0')
        time.sleep(0.15)
        run('ip','neighbor','del','192.0.2.8','dev','mn-demo0')
        run('ip','route','del','198.51.100.0/24','dev','mn-demo0','metric','123')
        run('ip','address','del','192.0.2.7/24','dev','mn-demo0')
        run('ip','link','del','mn-demo0')
        rest,err=process.communicate(timeout=8)
        assert process.returncode==0,err
    finally:
        if process.poll() is None:process.kill();process.wait()
    output=first+rest
    (OUT/'namespace-watch.jsonl').write_text(output)
    records=[json.loads(line) for line in output.splitlines()]
    events=[r['event'] for r in records if r['kind']=='event']
    tags={e[0] for e in events}
    summary=records[-1]['state']
    replay=json.loads(run(BINARY,'replay',record).stdout)['state']
    assert summary==replay,'record/replay drift'
    assert not summary['stale']
    assert not summary['links'] and not summary['addresses'] and not summary['routes'] and not summary['neighbors'],summary
    required={'LinkChanged','AddressChanged','RouteChanged','NeighborChanged'}
    assert required<=tags,(required,tags)
    assert len(events)>=10,len(events)
    details={'event_count':len(events),'datagrams':records[-1]['datagrams'],'types':sorted(tags),'replay_equal':True,'final_objects':0,'host_network_untouched':True}
    save('namespace-report.json',details)
    print(json.dumps(details))
def main():
    parser=argparse.ArgumentParser(); parser.add_argument('--namespace-worker',action='store_true'); args=parser.parse_args()
    if args.namespace_worker:namespace_events();return
    report={'platform':os.uname().sysname,'kernel':os.uname().release,'toolchain':run('moon','version','--all').stdout,'snapshot':snapshot_test(),'cli':cli_test(),'generic_controller':family_test()}
    # Only this temporary namespace worker can alter network configuration.
    probe=run('sudo','-n','unshare','-n','true',check=False)
    if probe.returncode==0:
        p=run('sudo','-n','unshare','-n','env','MOONNETLINK_ISOLATED=1',sys.executable,__file__,'--namespace-worker')
        report['isolated_events']=json.loads(p.stdout)
    else:report['isolated_events']={'skipped':True,'reason':'no isolated network namespace permission','stderr':probe.stderr}
    save('linux-integration-report.json',report)
    print(json.dumps(report,ensure_ascii=False,indent=2))
if __name__=='__main__':main()
