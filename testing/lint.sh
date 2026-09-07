#!/usr/bin/env bash
set -Eeuo pipefail; cd "$(dirname "$0")/.."; fail=0
mapfile -t sh < <(grep -rlE '^#!/(usr/bin/env )?bash' build_files system_files build.sh 2>/dev/null)
shellcheck -S warning "${sh[@]}" && echo "shellcheck: ok" || fail=1
mapfile -t py < <(grep -rlE '^#!/usr/bin/env python3' system_files; find system_files branding -name '*.py')
python3 -c 'import ast,sys; [ast.parse(open(f).read(), f) for f in sys.argv[1:]]' "${py[@]}" && echo "python: ok" || fail=1   # ast.parse never writes __pycache__
for l in packages/*.list; do grep -vE '^\s*(#|$)' "$l" | awk '{print $1}' | grep -qE '[^A-Za-z0-9.+:*_-]' && { echo "bad name in $l"; fail=1; }; done; echo "manifests: ok"
python3 -c "import xml.dom.minidom,sys,json; [xml.dom.minidom.parse(f) for f in sys.argv[1:3]]; json.load(open(sys.argv[3]))" system_files/usr/share/polkit-1/actions/org.snormium.policy branding/snormium-logo.svg system_files/usr/share/plasma/look-and-feel/org.snormium.desktop/metadata.json && echo "xml/json: ok" || fail=1
grep -q "example.org" snormium.env && { echo "FAIL: DISTRO_HOME_URL is the example.org placeholder"; fail=1; }
grep -q "^FROM \${BASE_IMAGE}" Containerfile && echo "containerfile: ok" || { echo "containerfile FROM missing"; fail=1; }
exit $fail
