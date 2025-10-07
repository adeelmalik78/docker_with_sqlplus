# Liquibase Docker image with SQLPLUS
by: Adeel Malik (Liquibase)
By: Adeel Malik

## Prerequisites
Download Oracle `instantclient-basic` and `instantclient-sqlplus`.

``` sh
curl -o instantclient-basic-linux.zip https://download.oracle.com/otn_software/linux/instantclient/2380000/instantclient-basic-linux.x64-23.8.0.25.04.zip -SL
curl -o oracle-instantclient-sqlplus.zip https://download.oracle.com/otn_software/linux/instantclient/2380000/instantclient-sqlplus-linux.x64-23.8.0.25.04.zip -SL
```

## Dockerfile

Here is the [Dockerfile](Dockerfile.sqlplus) to use which builds on Liquibase Pro version 4.32.0 and adds Oracle SQLPlus version 23.8.0.25.04. 

``` Dockerfile
FROM liquibase:4.32.0

# Install SQLPlus
USER root
RUN apt-get update && apt-get -y install unzip libaio1 libaio-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir /opt/oracle
# You must already have the sqlplus archives downloaded from Oracle
COPY oracle-instantclient-sqlplus.zip instantclient-basic-linux.zip ./

RUN sh -c 'unzip -oq "*.zip" -d /opt/oracle/' 
RUN rm *.zip
# RUN ls -alh /opt/oracle/instantclient_23_8

# Set SQLPlus Env Vars
ENV PATH="$PATH:/opt/oracle/instantclient_23_8"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/oracle/instantclient_23_8"

# Return to liquibase user space
USER liquibase
```

## Build the new Docker Image

Build the new docker image using the Dockerfile above:

``` sh
sudo docker build -f Dockerfile.sqlplus -t liquibase-with-sqlplus:1.0 .
```

The new docker image will be called liquibase-with-sqlplus and tagged 1.0.

```
% docker images
REPOSITORY               TAG       IMAGE ID       CREATED        SIZE
liquibase-with-sqlplus   1.0       99953e2a4a2d   3 hours ago    1.19GB
```

## Using the new Docker Image

Here is an example of how to use the new Docker image:

``` sh
sudo docker run \
  --rm \
  --env LIQUIBASE_LICENSE_KEY=$LIQUIBASE_PRO_LICENSE_KEY \
  --env LIQUIBASE_SQLPLUS_PATH=/opt/oracle/instantclient_23_8/sqlplus \
  --env LIQUIBASE_LOG_LEVEL=FINE \
  -v ${PWD}/changelog:/liquibase/changelog \
  liquibase-with-sqlplus:1.0 \
  --version

sudo docker run \
  --rm \
  --env LIQUIBASE_LICENSE_KEY=$LIQUIBASE_PRO_LICENSE_KEY \
  --env LIQUIBASE_SQLPLUS_PATH=/opt/oracle/instantclient_23_8/sqlplus \
  --env LIQUIBASE_LOG_LEVEL=FINE \
  -v ${PWD}/changelog:/liquibase/changelog \
  liquibase-with-sqlplus:1.0 \
  --url=jdbc:oracle:thin:@cs-oracledb.liquibase.net:1521/PP_DEV \
  --changeLogFile=changelog/db.changelog-master.xml \
  --username=liquibase_user \
  --password=liquibase_user \
  status
```

