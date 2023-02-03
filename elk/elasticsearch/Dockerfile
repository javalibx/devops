ARG ELK_VERSION=7.6.2
FROM elasticsearch:${ELK_VERSION}

ARG ELK_VERSION=7.6.2
RUN sh -c '/bin/echo -e "y" | /usr/share/elasticsearch/bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v'${ELK_VERSION}'/elasticsearch-analysis-ik-'${ELK_VERSION}'.zip'

EXPOSE 9200 9300