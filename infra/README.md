# infra/

Ansible playbooks + bootstrap scripts to take DSX Air nodes from "freshly provisioned" to "Docker-ready data platform host."

## Layout

```
infra/
  ansible/
    ansible.cfg
    inventory.ini.example
    group_vars/
      all.yml
    playbooks/
      00-bootstrap.yml          # users, sudo, ntp, sysctl, hostname
      01-docker.yml             # docker engine + compose plugin
      02-platform.yml           # per-session compose up
      03-observability.yml      # prom + grafana + loki
    roles/
      common/
      docker/
      compose-deploy/
      secrets/
  scripts/
    bootstrap-node.sh           # one-shot fallback for manual SSH bootstrap
    install-docker.sh
  secrets/
    age.pub                     # public SOPS recipient
```

## Inventory generation

`inventory.ini.example` is committed. After `make sim-export`, a real `inventory.ini` is generated with the actual OOB IPs of your simulation. The real file is gitignored.

## Idempotency

All playbooks are safe to re-run. CI dry-runs them on every PR via `make ansible-check`.
