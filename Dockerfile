FROM alpine:3.14

COPY entrypoint.sh /entrypoint.sh
COPY organization.payload /tmp/organization.payload
COPY variable.payload /tmp/variable.payload
COPY workspace.payload /tmp/workspace.payload

RUN apk update && \
    apk add curl jq

ENTRYPOINT ["/entrypoint.sh"]
