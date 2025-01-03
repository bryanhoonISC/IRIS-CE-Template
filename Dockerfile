ARG IMAGE=intersystemsdc/irishealth-community
ARG IMAGE=intersystemsdc/iris-community
ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2024.3
FROM $IMAGE

# USER root
# RUN apt-get update && apt-get -y upgrade \ 
#  && apt-get -y install unattended-upgrades

USER 51773

WORKDIR /home/irisowner/dev

ARG NAMESPACE="IRISAPP"

# create Python env, uncomment below 3 lines to set up python requirements
## Embedded Python environment
# ENV IRISUSERNAME="_SYSTEM"
# ENV IRISPASSWORD="SYS"
ENV IRISNAMESPACE=$NAMESPACE
ENV PYTHON_PATH=/usr/irissys/bin/
ENV PATH="/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin:/home/irisowner/.local/bin"

RUN --mount=type=bind,src=.,dst=. \
# uncomment below line to install python requirements
    # pip3 install -r requirements.txt && \
    iris start IRIS && \
    iris merge IRIS merge.cpf && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly
