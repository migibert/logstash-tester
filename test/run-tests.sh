#!/bin/bash
if [[ $1 == "all" || $1 == "patterns" ]]; then
    echo "###  RUN PATTERN TESTS    #####################"
    rspec -f p /test/spec/patterns_spec.rb
fi

if [[ $1 == "all" || $1 == "filters" ]]; then
    echo "###  RUN Logstash --configtest ################"
    if [[ $2 == "y" ]]; then
        logstash --configtest -f /etc/logstash/conf.d/
    fi

    echo "###  RUN FILTER Tests  ####################"
    rspec -f p /test/spec/filter_spec.rb
fi

