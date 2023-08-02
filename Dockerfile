FROM confluentinc/cp-server-connect:7.3.4

ADD pluginpath/* /usr/share/confluent-hub-components
ADD classpath/* /etc/kafka-connect/jars/
