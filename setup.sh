# Cleanup
rm -rf instantclient-basic-linux.zip
rm -rf oracle-instantclient-sqlplus.zip

# Fetch Instant Client with sqlplus
curl -o instantclient-basic-linux.zip https://download.oracle.com/otn_software/linux/instantclient/2380000/instantclient-basic-linux.x64-23.8.0.25.04.zip -SL
curl -o oracle-instantclient-sqlplus.zip https://download.oracle.com/otn_software/linux/instantclient/2380000/instantclient-sqlplus-linux.x64-23.8.0.25.04.zip -SL

#Build the docker image with sqlplus
sudo docker build -f Dockerfile.sqlplus -t liquibase-with-sqlplus:1.0 .


# The "--platform=linux/amd64" argument is needed if invoking docker run on a Mac
sudo docker run \
  --rm \
  --env LIQUIBASE_LICENSE_KEY=$LIQUIBASE_PRO_LICENSE_KEY \
  --env LIQUIBASE_SQLPLUS_PATH=/opt/oracle/instantclient_23_8/sqlplus \
  --env LIQUIBASE_LOG_LEVEL=INFO \
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

# sudo docker run \
#   --rm \
#   --env LIQUIBASE_LICENSE_KEY=$LIQUIBASE_PRO_LICENSE_KEY \
#   --env LIQUIBASE_SQLPLUS_PATH=/opt/oracle/instantclient_23_8/sqlplus \
#   --env LIQUIBASE_LOG_LEVEL=INFO \
#   -v ${PWD}/changelog:/liquibase/changelog \
#   liquibase-with-sqlplus:1.0 \
#   --url=jdbc:oracle:thin:@cs-oracledb.liquibase.net:1521/PP_DEV \
#   --changeLogFile=changelog/db.changelog-master.xml \
#   --username=ADEEL \
#   --password=ADEEL#MALIK \
#   status


# Troubleshooting commands

# sudo docker run -it \
#   --rm \
#   liquibase-with-sqlplus:1.0 \
#   sh -c "sqlplus ADEEL/ADEEL#MALIK@cs-oracledb.liquibase.net:1521/PP_DEV"

# sudo docker run -it \
#   --rm \
#   liquibase-with-sqlplus:1.0 \
#   sh -c "ls -alh /opt/oracle/instantclient_23_8/network/admin"


sudo docker run -it \
  --rm \
  liquibase-with-sqlplus:1.0 \
  sh ./test_sqlplus.sh
