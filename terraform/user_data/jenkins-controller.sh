#!/bin/bash

mkdir -p /srv/jenkins_home

while true; do
  if [ -b /dev/nvme1n1 ]; then
    break
  fi
  echo "Waiting for EBS volume"
  sleep 5
done

if ! grep -q /srv/jenkins_home /etc/fstab; then
  UUID=$(blkid -s UUID -o value /dev/nvme1n1)
  echo "UUID=$UUID /srv/jenkins_home ext4 defaults,nofail 0 2" >> /etc/fstab
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
  sleep 2
done

docker run -d \
    --name jenkins-controller \
    --restart unless-stopped \
    -p 8080:8080 \
    -v /srv/jenkins_home:/var/jenkins_home \
    jenkins/jenkins:2.533-jdk21

