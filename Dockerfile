FROM logstash:2.3.4


ENV http_proxy $HTTP_PROXY
ENV https_proxy $HTTPS_PROXY
ENV no_proxy $NO_PROXY

RUN logstash-plugin install --no-verify --development

ARG LST
ADD $LST/test/run-tests.sh /test/

ENTRYPOINT ["/test/run-tests.sh"]
