FROM debricked/cli:latest-resolution-debian

RUN apt-get update && apt-get -y install --no-install-recommends git && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY pipe /
RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
