FROM alpine:3.11

LABEL maintainer p.rzymski@kainos.com

# The path to the AWS IAM service account to use when uploading backups.
#ENV IAM_SERVICE_ACCOUNT_KEY_PATH ""
# The authorization header to use when calling the Nexus API.
ENV NEXUS_AUTHORIZATION "Basic YWRtaW46YWRtaW4xMjMK"

# The directory to which the Nexus 'backup-2' task will produce its output.
ENV NEXUS_BACKUP_DIRECTORY="/nexus-data/backup"

# The Nexus data directory.
ENV NEXUS_DATA_DIRECTORY="/nexus-data"

# The pod-local host and port at which Nexus can be reached.
ENV NEXUS_LOCAL_HOST_PORT "localhost:8081"

# The names of the repositories we need to take down to achieve a consistent backup.
ENV OFFLINE_REPOS "maven-central maven-public maven-releases maven-snapshots"

# The name of the GCS bucket to which the resulting backups will be uploaded.

ENV TARGET_BUCKET "s3://nexus-backup"
# The amount of time in seconds to wait between stopping repositories and starting the upload.
ENV GRACE_PERIOD "60"

WORKDIR /tmp

RUN apk add --no-cache --update bash ca-certificates curl inotify-tools python3 pip3 openssl
RUN pip3 install --upgrade --user awscli=1.16.309

ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD /scripts/start-repository.groovy /scripts/start-repository.groovy
ADD /scripts/stop-repository.groovy /scripts/stop-repository.groovy

ENTRYPOINT ["/docker-entrypoint.sh"]
