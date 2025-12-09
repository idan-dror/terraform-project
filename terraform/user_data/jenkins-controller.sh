#!/bin/bash

systemctl enable --now docker || true

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

docker run -d \
    --name jenkins-controller \
    --restart unless-stopped \
    -p 8080:8080 \
    -v /srv/jenkins_home:/var/jenkins_home \
    jenkins/jenkins:2.533-jdk21
