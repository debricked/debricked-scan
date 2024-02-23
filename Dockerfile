FROM debricked/cli:latest-resolution-debian

RUN apk add --no-cache bash git

COPY pipe /
RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
