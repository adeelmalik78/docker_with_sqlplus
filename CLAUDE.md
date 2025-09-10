# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based Liquibase setup that integrates Oracle SQLPlus with Liquibase Pro 4.32.0. The project creates a custom Docker image that combines Liquibase database migration capabilities with Oracle SQLPlus for executing Oracle-specific SQL operations.

## Key Components

- **Dockerfile.sqlplus**: Custom Dockerfile that extends the official Liquibase image with Oracle Instant Client 23.8.0.25.04 and SQLPlus
- **setup.sh**: Main build and execution script that downloads Oracle Instant Client, builds the Docker image, and runs various Liquibase commands
- **changelog/**: Directory containing Liquibase XML changelog files with database migrations
- **liquibase.flowfile.yaml**: Liquibase Flow configuration defining deployment stages (Status, Update)
- **liquibase.sqlplus.conf**: SQLPlus configuration for Liquibase (mostly commented out)
- **test_sqlplus.sh**: SQLPlus connection testing script

## Common Commands

### Build Docker Image
```bash
# Download Oracle Instant Client and build image
./setup.sh
```

Or manually:
```bash
# Download Oracle Instant Client
curl -o instantclient-basic-linux.zip https://download.oracle.com/otn_software/linux/instantclient/2380000/instantclient-basic-linux.x64-23.8.0.25.04.zip -SL
curl -o oracle-instantclient-sqlplus.zip https://download.oracle.com/otn_software/linux/instantclient/2380000/instantclient-sqlplus-linux.x64-23.8.0.25.04.zip -SL

# Build Docker image
sudo docker build -f Dockerfile.sqlplus -t liquibase-with-sqlplus:1.0 .
```

### Run Liquibase Commands
```bash
# Check Liquibase version
sudo docker run --rm --env LIQUIBASE_LICENSE_KEY=$LIQUIBASE_PRO_LICENSE_KEY liquibase-with-sqlplus:1.0 --version

# Check database status
sudo docker run --rm \
  --env LIQUIBASE_LICENSE_KEY=$LIQUIBASE_PRO_LICENSE_KEY \
  --env LIQUIBASE_SQLPLUS_PATH=/opt/oracle/instantclient_23_8/sqlplus \
  -v ${PWD}/changelog:/liquibase/changelog \
  liquibase-with-sqlplus:1.0 \
  --url=jdbc:oracle:thin:@cs-oracledb.liquibase.net:1521/PP_DEV \
  --changeLogFile=changelog/db.changelog-master.xml \
  --username=liquibase_user \
  --password=liquibase_user \
  status

# Run Liquibase Flow
sudo docker run --rm \
  --env LIQUIBASE_LICENSE_KEY=$LIQUIBASE_PRO_LICENSE_KEY \
  --env LIQUIBASE_SQLPLUS_PATH=/opt/oracle/instantclient_23_8/sqlplus \
  --env LIQUIBASE_COMMAND_USERNAME=ADEEL \
  --env LIQUIBASE_COMMAND_PASSWORD="ADEEL#MALIK " \
  -v ${PWD}/changelog:/liquibase/changelog \
  liquibase-with-sqlplus:1.0 \
  --url=jdbc:oracle:thin:@cs-oracledb.liquibase.net:1521/PP_DEV \
  --changeLogFile=changelog/db.changelog-master.xml \
  flow
```

### Test SQLPlus Connection
```bash
sudo docker run -it --rm liquibase-with-sqlplus:1.0 sh test_sqlplus.sh
```

## Architecture Notes

- The Docker image extends `liquibase:4.32.0` and adds Oracle Instant Client for SQLPlus support
- SQLPlus is installed at `/opt/oracle/instantclient_23_8/sqlplus` inside the container
- Changelog files use `runWith="sqlplus"` attribute to execute SQL through SQLPlus instead of JDBC
- Environment variables `LIQUIBASE_SQLPLUS_PATH` and `LIQUIBASE_LICENSE_KEY` are required
- Database connection uses Oracle TNS format: `cs-oracledb.liquibase.net:1521/PP_DEV`

## Configuration

- **Oracle Connection**: TNS connection string format used throughout
- **Credentials**: Username/password can be set via environment variables or command line
- **Log Level**: Configurable via `LIQUIBASE_LOG_LEVEL` (INFO, FINE, etc.)
- **Platform**: Use `--platform=linux/amd64` when running on Mac

## Important Files

- `changelog/db.changelog-master.xml`: Main changelog file that includes other changesets
- `changelog/000-sqlplus.xml`: Contains SQLPlus-specific changesets for creating tables
- `liquibase.flowfile.yaml`: Defines the Flow stages for validation, status checks, and updates