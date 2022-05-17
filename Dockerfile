FROM alpine:3.14

RUN apk add --update --no-cache curl git bash gnupg

COPY . .

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
