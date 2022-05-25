FROM alpine:3.15.0

RUN apk update && \
    apk --no-cache add curl jq coreutils

FROM pactfoundation/pact-cli:latest
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]