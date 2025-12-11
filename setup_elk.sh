#!/bin/bash
set -e

apt-get update
apt-get install -y docker.io docker-compose git

systemctl start docker
systemctl enable docker

SMTP_USER=$(gcloud secrets versions access latest --secret="EMAIL")
SMTP_PASSWORD=$(gcloud secrets versions access latest --secret="EMAILPW")

if [ ! -d "/opt/elk-stack/.git" ]; then
  echo "ELK stack repo does not exist — cloning..."
  git clone https://github.com/betterwse/bw-elk-stack /opt/elk-stack
else
  if [[ -n $(git -C /opt/elk-stack status --porcelain 2>/dev/null) ]]; then
    echo "Local changes detected — deleting and recloning repo..."
    rm -rf /opt/elk-stack
    git clone https://github.com/betterwse/bw-elk-stack /opt/elk-stack
  else
    echo "No local changes — pulling latest changes..."
    git -C /opt/elk-stack pull
  fi
fi

cd /opt/elk-stack

cat <<EOF >/opt/elk-stack/.env
GF_SMTP_USER=$SMTP_USER
GF_SMTP_PASSWORD=$SMTP_PASSWORD
EOF

docker-compose down
docker-compose up -d


#Run `chmod +x vm/scripts/setup_elk.sh` before terraform apply.
#you only need to run chmod again if the file permissions get reset
#(for example, a fresh git checkout in a new pipeline runner).

#You do NOT need to rerun it just because you destroy and reapply.
#The script content is what matters, not the executable bit.


