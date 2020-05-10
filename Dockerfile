FROM node:lts-alpine3.11
RUN apk add --update --no-cache \
    dumb-init \
    bash \
    curl \
    jq \
    git \
    postgresql-client \
    mysql-client \
    redis \
    # https://stackoverflow.com/questions/50288034/unsatisfiedlinkerror-tmp-snappy-1-1-4-libsnappyjava-so-error-loading-shared-li
    libc6-compat \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2

ENV CODE_SERVER_VERSION "3.2.0"
RUN mkdir /usr/lib/code-server \
    && curl -sSL https://github.com/cdr/code-server/releases/download/${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-x86_64.tar.gz | tar -xz -C /usr/lib/code-server --strip=1

ENV CF_CLI_VERSION "6.51.0"
RUN curl -sSL "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_CLI_VERSION}" | tar -xz -C /usr/local/bin

RUN addgroup coder \
    && adduser -G coder -s /bin/bash -D coder
ENV SHELL=/bin/bash
USER coder
WORKDIR /home/coder

EXPOSE 8080
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "/usr/lib/code-server/out/node/entry.js", "--disable-updates", "--disable-telemetry", "--bind-addr", "0.0.0.0:8080", "."]
