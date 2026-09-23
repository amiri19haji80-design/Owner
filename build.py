python3 - <<'PY'
gw = '''  gateway:
    image: "cmppcia-docker.artifactory.cib.echonet:443/nginx:alpine"
    networks:
      - api-net
      - perimeter
    configs:
      - source: api_gateway_conf_v1.0
        target: /etc/nginx/conf.d/default.conf
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.hostname == eurvliii120783
      restart_policy:
        condition: any
        delay: 5s
      resources:
        reservations:
          memory: 64M
'''
lines = open('qdi-api.yml').read().splitlines(keepends=True)
out, inserted = [], False
for l in lines:
    if l.startswith('  celery-worker:') and not inserted:
        out.append(gw); inserted = True
    out.append(l)
open('qdi-api.yml','w').write(''.join(out))
print("inserted:", inserted)
import yaml
d = yaml.safe_load(open('qdi-api.yml'))
print(list(d['services']))
print(list(d['services']['gateway']))
PY
