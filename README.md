## Overview

oqtane.docker provides a set of scripts an configuration files to run [Oqtane Framework](https://github.com/oqtane/oqtane.framework) in docker. 

## Basic concept

[Oqtane Framework](https://github.com/oqtane/oqtane.framework) is a very flexible framework and allows installation of modules, themes and languages which can be installed through the admin GUI. Docker containers are usually a more static concept, where a prebuild image is used to run the application. When extensions are installed later on, they would be copied into the current container and would be lost ist the container is recreated. To overcome this, oqtane.docker proposes to run oqtane from a local folder outside the docker container and keep the flexibility even on linux.

The setup scripts are designed to run oqtane from folder /srv/oqtane. If this does not match with your environment it can be easily changed.

### What will be installed

| Container | Purpose            | Remarks                                                                  |
| :-------- | :----------------- | :----------------------------------------------------------------------- |
| oqtane    | oqtane application | All binaries are located in /srv/oqtane/app                              |
| mysql     | mysql database     | holds all oqtane databases.                                              |
| adminier  | adminier web app   | mysql administration. It is intended to be reachable only via ssh tunnel |


_note:_ If you want to use MS SQL Express or PostgreSQL instead feel free to replace mysql definition. Should work as well. adminer should support all of them. Details can be found here: [adminer](https://www.adminer.org/)

### Prerequisites

**caddy reverse proxy**

The setup has been tested with [caddy](https://caddyserver.com/) reverse proxy installed outside of docker. It would be possible to run caddy in a docker container as well. But this could introduce dependencies to other containerized applications, which might not be wanted.

**Fair knowledge of docker**

The setup uses [docker compose](https://docs.docker.com/compose/) to run the containers. This has been chosen for simplicity and does not require extra care for firewall setup.

**PowerShell**

powershell is available on linux. To install, follow this [Install powershell on linx](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-linux?view=powershell-7.5). 

### SSL/TLS Management

On linux systems it is common to employ free certificates from letsencrypt or zerossl. docker.oqtane uses [caddy](https://caddyserver.com/) reverse proxy for certificate management and SSL/TLS handling and http to https redirection. Other reverse proxy engines like nginx, traffic or apache should work as well.
asp net core usually has its own [https redirection](https://learn.microsoft.com/en-us/aspnet/core/security/enforcing-ssl?view=aspnetcore-10.0&tabs=visual-studio%2Clinux-sles) and oqtane makes use of it. The settings variable INSTALLATION:UseHttpsRedirection is used to turn off https redirection. It is recommended to use this setting as additional environment variable or put in appsettings.override.json (see next heading).

### Optional appsettings override

Normally oqtane store application settings in appsettings.json located in the same folder as the oqtane binaries. To avoid overwriting this file when oqtane binaries are updated and in screnarios with distributed development it is useful to have the settings store outside oqtane binary folder. The environment variable OQTANE_APPSETTINGS_PATH can be used to specify the path to appsettings.override.json (fixed filename, must contain a valid json content). When specified, oqtan stores settings in appsettings.override.json.

## Getting started

**Prepare your linux installation**

* Install Latest **[.NET  10.0 SDK](https://dotnet.microsoft.com/en-us/download)**.
* clone or copy oqtane.docker to you local disk on linux
* [Install caddy](https://caddyserver.com/docs/install#debian-ubuntu-raspbian) (I prefer to run caddy outside docker as this lowers the dependency between docker containers)
* Setup the Caddyfile (sample in scripts/caddy/Caddyfile)
* [Install powershell](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-linux?view=powershell-7.5) Note: On debian 13 you need to install libicu74_74 before. The script  scripts/pwsh/install-pwsh.sh includes this step for debian 13. In case you are 

* Update ./scripts/oqtane/setup/createFolders.ps1 to your needs. 
* Setup the necessary folders from powershell prompt run
```
./scripts/oqtane/setup/createFolders.ps1
```
**Install Oqtane Application Source Code**

Follow the instructions in [Oqtane Framework](https://github.com/oqtane/oqtane.framework) to install the prerequistes and the source code on your machine. You may use the project template or git clone approach. You may do this either on target linux system or on your local machine.

**Build an publish oqtane**

* run ./scripts/oqtane/build/publishOqtane.ps1 on the system where you installed the oqtane source code
This script will build and publish oqtane and create a zip archive which has to be transfered to the target machine. I usually use scp for this.
* Unzip the transferred archive to the app folder specified in scripts/oqtane/setup/createFolders.ps1 
When running in powershell, you can use following commands to copy oqtane binaries to the target installation folder:
```
cd <folder containg zip from build>
expand-archive -Path ./oqtane-10.0.4.zip -DestinationPath app/
sudo cp -r app/* /<your oqtane app directory>/oqtane/app/
```

**Adopt the sample scripts to your needs**

* Update the files docker-compose.yml, oqtane.env, mysqldb.env in ./scripts/docker to your needs and to match the folder structure in scripts/oqtane/setup/createFolders.ps1

**Start oqtane**

* Make shure caddy is up and running
```
sudo systemctl status caddy
```
* Optional replace mysql and adminier in docker-compose.yml with your prefered database
* Start oqtane with
```
cd scripts/oqtane/docker/
sudo docker compose up -d
```
* Verify that oqtane container is running:
```
sudo docker compose ps
sudo docker compose logs
```
* Browse to the Url specified in Caddyfile to run the application
  * caddy should have applied for a valid certificate
  * If you are running oqtane with a local domain caddy will create a certificate as described in [Automatic HTTPS](https://caddyserver.com/docs/automatic-https#local-https), heading [Hostname requirements](https://caddyserver.com/docs/automatic-https#hostname-requirements). This certificate can then be installed on the machine from where you access oqtane. 

**_NOTE_** Although restarting oqtane from GUI basically works, it could be sometimes required to restart the docker container:
```
sudo docker compose restart oqtane
```
## oqtane.docker contents

| Filename                          | Purpose                                                                             | Remarks                                                                   |
| :-------------------------------- | :---------------------------------------------------------------------------------- | :------------------------------------------------------------------------ |
| Folder: caddy<td colspan=3></td>  |                                                                                     |                                                                           |
| Caddyfile                         | reverse proxy configuration                                                         | configure here your urls for oqtane                                       |
| Folder: docker<td colspan=3></td> |                                                                                     |                                                                           |
| appsettings.override.json         | oqtane appsettings file                                                             | will be copied to specified folder when setupFolders.ps1 is executed      |
| docker-compose.yml                | docker compose configuration                                                        | May requrire modification, when oqtane application base folder is changed |
| mysqldb.env                       | Envrionment variables for mysql                                                     |                                                                           |
| oqtane_502.html                   | Page to be shown when oqtane is offline                                             | Change to you needs                                                       |
| oqtane.env                        | Envrionment variables for oqtane                                                    | Ports may require adoption, must match port in Caddyfile.                 |
| Folder: docker<td colspan=3><td>  |                                                                                     |                                                                           |
| setupFolders.ps1                  | Script to create all folders needed, and copy appsettings.override.json to /app/ini | Adopt to your needs. It is recommended to keep the basic folder structure and change only the top level folder name. <br/>If you change, review all the other files to match the new folder name                                                     |

**oqtane Environment Variables**

| Variable                          | Value          | Remarks                                                                                                                |
| :-------------------------------- | :------------- | :--------------------------------------------------------------------------------------------------------------------- |
| ASPNETCORE_URLS                   | http:[]()://+:51080 | This worked best, only the port maybe changed                                                                          |
| ASPNETCORE_ENVIRONMENT            | Release        | asp net core Environment                                                                                               |
| ASPNETCORE_HTTP_PORTS             | 51080          | asp net http port must match ASPNETCORE_URLS and Caddyfile                                                             |
| OQTANE_APPSETTINGS_PATH           | /ini           | Path to appsettings.override.json, must match value in docker-compose.yml                                              |
| INSTALLATION__USEHTTPSREDIRECTION | false          | Tells oqtane not to use https redirection. Requires two underscore chars, because it is used as configuration variable |

## Post Installation Tasks

### oqtane database configuration

* mysql server name is oqtane_db and can be found in docker-compose.yml. The setup uses the standard port 3306 of mysql. 
* mysql network is configured as internal and should not be exposed outside docker

### oqtane module or theme installation

* Module and Theme installation should work as usual. Package folder is /srv/oqtane/app.
* Restarting oqtane should work from inside oqtane
