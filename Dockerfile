FROM alpine:3.7

RUN apk add --no-cache \
        docker \
        curl \
        python \
        py-pip \
        groff \
        less \
        mailcap \
    && pip install awscli \
    && apk -v --purge del py-pip

COPY ./bin /bin
RUN chmod 755 /bin/loop-aws-ecr-login.sh

VOLUME /root/.aws
VOLUME /project
WORKDIR /project

CMD ["/bin/loop-aws-ecr-login.sh"]
