FROM docker.elastic.co/logstash/logstash:9.2.1

RUN logstash-plugin install logstash-input-google_pubsub 
RUN logstash-plugin install logstash-filter-prune