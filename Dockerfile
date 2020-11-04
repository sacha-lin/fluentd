# AUTOMATICALLY GENERATED
# DO NOT EDIT THIS FILE DIRECTLY, USE /Dockerfile.template.erb

FROM alpine:3.12
LABEL maintainer "Fluentd developers <fluentd@googlegroups.com>"
LABEL Description="Fluentd docker image" Vendor="Fluent Organization" Version="1.11.2"

# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete' has no effect
RUN apk update \
 && apk add --no-cache \
        ca-certificates \
        tcpdump \
        ruby ruby-irb ruby-etc ruby-webrick \
        tini \
 && apk add --no-cache --virtual .build-deps \
        build-base linux-headers \
        ruby-dev gnupg \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.8.1 \
 && gem install json -v 2.3.0 \
 && gem install async-http -v 0.50.7 \
 && gem install ext_monitor -v 0.1.2 \
 && gem install fluentd -v 1.11.2 \
 && gem install bigdecimal -v 1.4.4 \
 && gem install fluent-plugin-secure-forward -v 0.4.5 \
 && gem install fluent-plugin-remote_syslog -v 1.0.0 \
 && gem install fluent-plugin-elasticsearch -v 4.2.0 \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem /usr/lib/ruby/gems/2.*/gems/fluentd-*/test

RUN addgroup -S fluent && adduser -S -g fluent fluent \
    # for log storage (maybe shared with host)
    && mkdir -p /fluentd/log \
    # configuration/plugins path (default: copied from .)
    && mkdir -p /fluentd/etc /fluentd/plugins /fluentd/certificate 

COPY fluent.conf /fluentd/etc/
COPY fluentd.crt /fluentd/certificate/fluentd.crt
COPY fluentd.key /fluentd/certificate/fluentd.key
COPY entrypoint.sh /bin/
RUN chown -R fluent /fluentd && chgrp -R fluent /fluentd

ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD=""
EXPOSE 24224 

USER root
ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]