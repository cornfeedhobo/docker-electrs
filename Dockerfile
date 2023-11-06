# Multistage docker build, requires docker 17.05

# Builder Stage
FROM alpine:3.18 as builder

ARG ELECTRS_VERSION
ARG ELECTRS_HASH

RUN set -ex && \
	test -n "${ELECTRS_VERSION}" && \
	test -n "${ELECTRS_HASH}"

RUN set -ex && apk --update upgrade
RUN set -ex && apk add \
		cargo \
		clang \
		clang-dev \
		cmake \
		g++ \
		git \
		rocksdb-dev

ENV ROCKSDB_INCLUDE_DIR=/usr/include
ENV ROCKSDB_LIB_DIR=/usr/lib

RUN set -ex && \
	git clone \
		--recursive --depth 1 -b ${ELECTRS_VERSION} \
		https://github.com/romanz/electrs.git && \
	cd electrs && \
	nice -n 19 \
		ionice -c2 -n7 \
			cargo install --locked --path .


# Runtime Stage
FROM alpine:3.18

ARG ELECTRS_VERSION
ARG ELECTRS_HASH

RUN set -ex && apk --update upgrade
RUN set -ex && apk add \
		ca-certificates \
		numactl-tools \
		rocksdb

COPY --from=builder /root/.cargo/bin/electrs /usr/bin/electrs

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "electrs" ]

EXPOSE 50001

# Labels, for details see http://label-schema.org/rc1/
ARG BUILD_DATE
LABEL maintainer="github.com/cornfeedhobo/docker-electrs"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.name="cornfeedhobo/electrs"
LABEL org.label-schema.description="Built from source electrs Docker images based on Alpine Linux"
LABEL org.label-schema.url="https://github.com/romanz/electrs"
LABEL org.label-schema.vcs-url="https://github.com/romanz/electrs"
LABEL org.label-schema.vcs-ref="${ELECTRS_HASH}"
LABEL org.label-schema.vendor="cornfeedhobo"
LABEL org.label-schema.version="${ELECTRS_VERSION}"
LABEL org.label-schema.docker.cmd="docker run -ditP cornfeedhobo/electrs"
