## IRIS-CommunityEdition-template
This is a template to work with InterSystems IRIS CE Image
It should be used as a starter kit on working with IRIS CE in CICD pipelines.
It leverages Durable %SYS to persist instance specific data (including data defined by User in Persistent Objects / Tables)

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation docker

Clone/git pull the repo into any local directory

```bash
$ git clone https://github.com/intersystems-community/iris-embedded-python-template.git
```

Open the terminal in this directory and run:

```bash
$ docker-compose build
```

3. Run the IRIS container with your project:

```bash
$ docker-compose up -d
```

### IRIS Initialization
In this template merge.cpf is used to initialize iris.
merge.cpf is a convenient way to setup different IRIS configuration settings. [Learn more about merge.cpf](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=RACS_cpf#:~:text=Use%20the%20iris%20merge%20command,is%20the%20instance's%20current%20iris.).

1. Using merge to initialize IRIS and create IRIS Database and Namespace
Notice [merge.cpf](https://github.com/intersystems-community/iris-embedded-python-template/blob/4c12d4b02770c7422c7553ee818a18c1871c3759/merge.cpf) file that is being implemented during docker image build in Dockerfile
```
iris merge IRIS merge.cpf && \
```
 that contains:
```
[Actions]
CreateResource:Name=%DB_IRISAPP_DATA,Description="IRISAPP_DATA database resource"
CreateDatabase:Name=IRISAPP_DATA,Directory=/usr/irissys/mgr/IRISAPP_DATA,Resource=%DB_IRISAPP_DATA
CreateResource:Name=%DB_IRISAPP_CODE,Description="IRISAPP_CODE database resource"
CreateDatabase:Name=IRISAPP_CODE,Directory=/home/irisowner/IRISAPP_CODE/,Resource=%DB_IRISAPP_CODE
CreateNamespace:Name=IRISAPP,Globals=IRISAPP_DATA,Routines=IRISAPP_CODE,Interop=1
ModifyService:Name=%Service_CallIn,Enabled=1,AutheEnabled=48
ModifyUser:Name=SuperUser,PasswordHash=a31d24aecc0bfe560a7e45bd913ad27c667dc25a75cbfd358c451bb595b6bd52bd25c82cafaa23ca1dd30b3b4947d12d3bb0ffb2a717df29912b743a281f97c1,0a4c463a2fa1e7542b61aa48800091ab688eb0a14bebf536638f411f5454c9343b9aa6402b4694f0a89b624407a5f43f0a38fc35216bb18aab7dc41ef9f056b1,10000,SHA512
```
As you can see it creates dabasases IRISAPP_DATA and IRISAPP_CODE for data and code, the related IRISAPP namespace to access it and the related resources %IRISAPP_DATA and %IRISAPP_CODE" to manage the access.

IRISAPP_DATA is created within the /usr/irissys/mgr folder while IRISAPP_CODE is created outside the Durable %SYS folder. This is to ensure that when the container instance uses the latest codes built and stored in IRISAPP_CODE within the container instead of the historical code DB in Durable %SYS.

Also it enables Callin service to make Embedded python work via ModifyService clause.
and it updates the password for the built-in user SuperUser to "SYS". The hash for this password is obtained via the following command:
```bash
docker run --rm -it containers.intersystems.com/intersystems/passwordhash:1.1 -algorithm SHA512 -workfactor 10000
```

2. Using python to initialize IRIS.
Often we used a special [iris.script](https://github.com/intersystems-community/iris-embedded-python-template/blob/d7c817865b48681e3454997906e1374b3baeef74/iris.script) file to run ObjectScript commands during the initialization - it is here just for the information.
It is being executed via the line in Dockerfile:
```
iris session IRIS < iris.script && \
```
the iris.script file contains examples how developer can initialize different services of iris via ObjectScript code.


## How to test it

1. Open IRIS terminal and run the ObjectScript Test() method to see if runs the script and returns values from IRIS:

```
$ docker-compose exec iris iris session iris -U IRISAPP
IRISAPP>write ##class(dc.sample.ObjectScript).Test()
It works!
42
```



2. Class `dc.sample.PersistentClass` contains a method `CreateRecord` that creates an object with one property, `Test`, and returns its id.

Open IRIS terminal and run:

```
IRISAPP>write ##class(dc.sample.PersistentClass).CreateRecord(.id)
1
IRISAPP>write id
1
```

In your case the value of id could be different. And it will be different with every call of the method.

You can check whether the record exists and try to right the property of the object by its id.

```
IRISAPP>write ##class(dc.sample.PersistentClass).ReadProperty(id)
Test string
```

#### Bind VSCode to the running IRIS container

Open VSCode in the project directory.

Go to the `docker-compose.yml` file, right-click on it and select `Compose Up`.

Once the container is up and running you can open the docker extension and right-click on the container name and select `Attach Visual Studio Code`.

### Working with Python libs from ObjectScript
Open IRIS terminal:

```objectscript
$ docker-compose exec iris iris session iris
USER>zn "IRISAPP"
```

```objectscript
IRISAPP>d ##class(dc.sample.ObjectScript).Test()

```
## DURABLE %SYS
To use Durable %SYS feature,
1. the volume mapping must be specified in the docker-compose.yml. In this case ../shared in the Host (one file dir up) is mapped to /shared in the Container.
```
    volumes:
      - ../shared:/shared
```
2. the ISC_DATA_DIRECTORY environment variable must be set. In this case, the Durable %SYS directory will be in the /dur subfolder in the /shared folder in the container / Host.
```
    environment:
      - ISC_DATA_DIRECTORY=/shared/dur
```

## What else is inside the repository

### .github folder

Contains two GitHub actions workflows:
1. `github-registry.yml`
    Once changes pushed to the repo, the action builds the docker image on Github side and pushes the image to Github registry that can be very convenient to further cloud deployement, e.g. kubernetes.
2. `objectscript-qaulity.yml`
    with every push to master or main branch the workflow launches the repo test on objectscript issues with Objectscript Quality tool, [see the examples](https://community.objectscriptquality.com/projects?sort=-analysis_date). This works if the repo is open-source only.

Both workflows are repo agnostic: so they work with any repository where they exist.

### .vscode folder
Contains two files to setup vscode environment:

#### .vscode/settings.json

Settings file to let you immediately code in VSCode with [VSCode ObjectScript plugin](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript))

#### .vscode/launch.json

Config file if you want to debug with VSCode ObjectScript

### src folder

Contains source files.
src/iris contains InterSystems IRIS Objectscript code

### usefulcommands.md

Contains a set of useful commands that will help during the development

### docker-compose.yml

A docker engine helper file to manage images building and rule ports mapping an the host to container folders(volumes) mapping

### Dockerfile

The simplest dockerfile which starts IRIS and imports code from /src folder into it.
Use the related docker-compose.yml to easily setup additional parametes like port number and where you map keys and host folders.


### iris.script

Contains objectscript commands that are feeded to iris during the image building. It includes a line to execute ```##class(DBSetup.Utils).SetupDBPermissions()``` to change IRISAPP_CODE DB to be ReadOnly.


## Troubleshooting

If you have issues with docker image building here are some recipes that could help.

1. You are out of free space in docker. You can expand the amount of space or clean up maually via docker desktop. Or you can call the following line to clean up:
```
docker system prune -f
```

2. We use multi-stage image building which in some cases doesn't work. Switch the target to [builder](https://github.com/intersystems-community/intersystems-iris-dev-template/blob/6ab6791983e5783118efce1777a7671046652e4c/docker-compose.yml#L7) from final in the docker compose and try again.

