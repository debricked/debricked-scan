FROM php:7.3-cli-alpine3.9

RUN apk update && apk add bash

COPY pipe /
RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
