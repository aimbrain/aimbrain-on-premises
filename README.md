# AimBrain platform on-premises deployment

## Installation

### Requirements

* RPM package manager

### Installation instructions

The easiest way to install the AimBrain platform is to use the `install.sh` script, which requires the yum package-management utility:

```
# ./install.sh <repo_username> <repo_password> <company_name> <app_name>
```

An example command would look like this:

```
# ./install.sh repo_username repo_password company-xyz demo-app
```

The command will also create a company, app and API key records in the database and output the API key and secret pair that can be used to send requests to the AimBrain platform.

### External dependencies

The `install.sh` script adds the [Extra Packages for Enterprise Linux (EPEL)](https://fedoraproject.org/wiki/EPEL) repository for some of AimBrain platform's dependencies:
* RabbitMQ
* Redis

## Service status

The service will by default listen to incoming requests on the 8080 port.

### Checking and changing service status

The status of the services can be checked by running:

```
sudo systemctl status aimbrain-api-service.service
sudo systemctl status aimbrain-aimbehaviour.service
```

The services can be restarted by running:

```
sudo systemctl restart aimbrain-api-service.service
sudo systemctl restart aimbrain-aimbehaviour.service
```

The services can be stopped by running:

```
sudo systemctl stop aimbrain-api-service.service
sudo systemctl stop aimbrain-aimbehaviour.service
```

The services can be started by running:

```
sudo systemctl start aimbrain-api-service.service
sudo systemctl start aimbrain-aimbehaviour.service
```

## Tested deployments
The `install.sh` script has been tested on the following distributions:

| Distribution | Deployment         |
| ------------ |:------------------:|
| RHEL 7.2     | :white_check_mark: |
| RHEL 7       | :white_check_mark: |
| CentOS 7.2   | :white_check_mark: |
| CentOS 7     | :white_check_mark: |
| Fedora 22    | :white_check_mark: |
