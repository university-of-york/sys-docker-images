FROM alpine:3.9

RUN apk update && apk add bash && apk add openssh && apk add rsync
COPY bitbucket-pipes-toolkit-bash/common.sh /common.sh
COPY pipe /

ENTRYPOINT ["/pipe.sh"]
