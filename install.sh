#!/bin/bash

set -eu

if [ $# -ne 4 ]
  then
  echo "usage: sudo ./install.sh <repo_username> <repo_password> <company_name> <app_name>"
  echo "example usage: sudo ./install.sh repo_username repo_password company demo-app"
  exit 1
fi

REPO_USERNAME=$1
REPO_PASSWORD=$2
API_COMPANY_NAME=$3
API_APP_NAME=$4

if [ -z "$REPO_USERNAME" ]
  then
  echo "Repository username not provided. Exiting..."
  exit 1
fi

if [ -z "$REPO_PASSWORD" ]
  then
  echo "Repository password not provided. Exiting..."
  exit 1
fi

if [ -z "$API_COMPANY_NAME" ]
  then
  echo "Company name not provided. Exiting..."
  exit 1
fi

if [ -z "$API_APP_NAME" ]
  then
  echo "App name not provided. Exiting..."
  exit 1
fi

API_PERMISSIONS='["write","read","debug"]'

PSQL=/usr/bin/psql
UUIDGEN=/usr/bin/uuidgen
TIMESTAMP=`date +"%Y-%m-%d %H:%M:%S"`

export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-aimbrain}
export PGUSER=${PGUSER-postgres}
export PGPASSWORD=${PGPASSWORD-postgres}

EPEL_FILE=epel-release-latest-7.noarch.rpm
EPEL_LOCATION=https://dl.fedoraproject.org/pub/epel/$EPEL_FILE

yum install -y wget bzip2
wget $EPEL_LOCATION -P /tmp/
rpm -ivh /tmp/$EPEL_FILE

cat > /etc/yum.repos.d/aimbrain-rpm-repo.repo <<EOF
[aimbrain-rpm-repo]
name=Aimbrain Test RPM Repository
baseurl=https://$REPO_USERNAME:$REPO_PASSWORD@rpm.aimbrain.com/\$basearch/
enabled=1
gpgkey=https://$REPO_USERNAME:$REPO_PASSWORD@rpm.aimbrain.com/RPM-GPG-KEY-Aimbrain
gpgcheck=1
EOF

yum install -y aimbrain

# Create a company
echo "Creating company..."
API_COMPANY_ID=$($PSQL -X -qtA -c "INSERT INTO companies (company_name, created_at, updated_at) VALUES \
    ('$API_COMPANY_NAME', '$TIMESTAMP', '$TIMESTAMP') RETURNING id;")
echo "Company id: $API_COMPANY_ID"

# Create an app
echo "Creating app..."
API_APP_ID=${API_COMPANY_NAME,,}"-"${API_APP_NAME,,}
API_APP_ID=$($PSQL -X -qtA -c "INSERT INTO apps (id, company_id, app_name, created_at, updated_at) VALUES \
    ('$API_APP_ID', '$API_COMPANY_ID', '$API_APP_NAME', '$TIMESTAMP', '$TIMESTAMP') RETURNING id;")
echo "App id: $API_APP_ID"

# Create API keys
echo "Creating API keys..."
API_KEY=$($UUIDGEN)
API_KEY=`echo ${API_KEY,,} | tr -d '\n'`
API_SECRET=$($UUIDGEN)$($UUIDGEN)
API_SECRET=`echo ${API_SECRET,,} | tr -d - | tr -d '\n'`
$PSQL -X -qtA -c "INSERT INTO api_keys (api_key, secret, permissions, app_id, created_at, updated_at) VALUES \
    ('$API_KEY', '$API_SECRET', '$API_PERMISSIONS', '$API_APP_ID', '$TIMESTAMP', '$TIMESTAMP');"
echo "API key pair: $API_KEY:$API_SECRET"

exit 0
