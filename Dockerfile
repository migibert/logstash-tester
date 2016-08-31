FROM logstash:2.3.4

RUN logstash-plugin install --no-verify --development

ARG LST
ADD $LST/test/run-tests.sh /test/

ENTRYPOINT ["/test/run-tests.sh"]
