FROM alpine:3.8
# Stress Version can be found on offcial website of stress
# https://people.seas.harvard.edu/~apw/stress/

# Build stress from source.
RUN STRESS_VERSION=1.0.4; \
    apk add --no-cache g++ make curl && \
    curl https://fossies.org/linux/privat/stress-${STRESS_VERSION}.tar.gz | tar xz && \
    cd stress-${STRESS_VERSION} && \
    ./configure && make && make install && \
    apk del --purge g++ make curl && rm -rf stress-*

ADD aewi-cluster-stress /usr/bin/aewi-cluster-stress
RUN ["chmod", "+x", "/usr/bin/aewi-cluster-stress"]
ENTRYPOINT ["/usr/bin/aewi-cluster-stress"]
