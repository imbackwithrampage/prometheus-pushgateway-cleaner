FROM clojure:openjdk-11-tools-deps-1.10.1.502 AS BASE

# Setup GraalVM
RUN apt-get update
RUN apt-get install --no-install-recommends -yy curl unzip build-essential zlib1g-dev
WORKDIR "/opt"
RUN curl -sLO https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-19.3.1/graalvm-ce-java8-linux-amd64-19.3.1.tar.gz
RUN tar -xzf graalvm-ce-java8-linux-amd64-19.3.1.tar.gz
ENV GRAALVM_HOME="/opt/graalvm-ce-java8-19.3.1"
RUN $GRAALVM_HOME/bin/gu install native-image

# Cache dependencies
COPY ./deps.edn ./deps.edn
RUN clojure -R:test:native-image -e ""
COPY . .

# Run tests
RUN clojure -Atest

# Build binary
RUN clojure -Anative-image

# Create minimal image
FROM scratch
COPY --from=BASE /opt/prometheus_pushgateway_cleaner /prometheus_pushgateway_cleaner
CMD ["/prometheus_pushgateway_cleaner"]
