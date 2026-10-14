"""Run the same MoonBit demos on JS/Wasm-GC and compare every output step."""
import json,pathlib,subprocess
root=pathlib.Path(__file__).resolve().parents[1]
out=root/'demo-output';out.mkdir(exist_ok=True)
report=[]
for example in ['replay','kernel_replay','family_replay']:
    results={}
    for target in ['wasm-gc','js']:
        p=subprocess.run(['moon','run','examples/'+example,'--target',target],cwd=root,capture_output=True,text=True,encoding='utf8',timeout=90,check=True)
        rows=[json.loads(line) for line in p.stdout.splitlines()]
        results[target]=rows
        (out/(example+'-'+target+'.jsonl')).write_text(p.stdout,encoding='utf8')
    assert results['wasm-gc']==results['js'],example+' backend output drift'
    if example=='kernel_replay':
        assert len(results['js'])==32
        assert results['js'][-1]['applied_events']==32 and not results['js'][-1]['stale']
    elif example=='replay':assert results['js'][-1]['stale']
    else:
        assert len(results['js'])==1 and results['js'][0]['metadata_and_ack_complete']
        assert results['js'][0]['family']['name']=='nlctrl'
    report.append({'example':example,'steps':len(results['js']),'targets':['wasm-gc','js'],'all_steps_equal':True})
(out/'portable-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
print(json.dumps(report,indent=2))
