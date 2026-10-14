"""Embed our isolated Linux capture for I/O-free cross-backend replay examples."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
lines=(root/'fixtures/namespace-events.jsonl').read_text(encoding='utf8').splitlines()
(root/'fixtures/capture.mbt').write_text('///|\n/// Generated from our isolated Linux capture; see fixtures/README.md.\npub fn journal_text() -> String {\n  let data =\n'+''.join('    #|'+line+'\n' for line in lines)+'  data\n}\n',encoding='utf8')
family=(root/'fixtures/nlctrl.jsonl').read_text(encoding='utf8').splitlines()
(root/'fixtures/family_capture.mbt').write_text('///|\n/// Generated from our read-only Linux nlctrl capture; see fixtures/README.md.\npub fn family_journal_text() -> String {\n  let data =\n'+''.join('    #|'+line+'\n' for line in family)+'  data\n}\n',encoding='utf8')
