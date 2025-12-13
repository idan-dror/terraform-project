#!/bin/bash

mkdir -p /srv/gitlab

while true; do
  if [ -b /dev/nvme1n1 ]; then
    break
  fi
  echo "Waiting for EBS volume to be attached"
  sleep 5
done

if ! grep -q /srv/gitlab /etc/fstab; then
  UUID=$(blkid -s UUID -o value /dev/nvme1n1)
  echo "UUID=$UUID /srv/gitlab ext4 defaults,nofail 0 2" >> /etc/fstab
fi

systemctl daemon-reload
mount -a

systemctl enable --now docker >/dev/null 2>&1 || true

while true; do
  if docker info >/dev/null 2>&1; then
    break
  fi
  echo "Waiting for Docker daemon..."
  sleep 2
done

while true; do
  if curl -fsS https://hub.docker.com/ >/dev/null; then
    break
  fi
  echo "Waiting for NAT gateway..."
  sleep 5
done

GITLAB_OMNIBUS_CONFIG=$(cat <<'EOF'
external_url 'https://git-tf.idror.net'
gitlab_rails['gitlab_shell_ssh_port'] = 2222
nginx['listen_https'] = false
nginx['listen_port'] = 80
nginx['redirect_http_to_https'] = false
nginx['proxy_set_headers'] = {
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl"   => "on"
}
EOF
)

docker run -d \
    --name gitlab \
    --restart unless-stopped \
    -p 80:80 \
    -p 2222:22 \
    -v /srv/gitlab/config:/etc/gitlab \
    -v /srv/gitlab/logs:/var/log/gitlab \
    -v /srv/gitlab/data:/var/opt/gitlab \
    --shm-size 256m \
    -e GITLAB_OMNIBUS_CONFIG="$GITLAB_OMNIBUS_CONFIG" \
    gitlab/gitlab-ce:18.5.0-ce.0