FROM node:10-alpine

ENV CI_TOOLS_PATH "/opt/ci-tools"
ENV CI_TOOLS_EXECUTABLE_PATH "$CI_TOOLS_PATH/bin"
ENV CI_TOOLS_DEPENDENCY_PATH "$CI_TOOLS_PATH/dep"

RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk update \
    && apk add --no-cache \
       bash \
       docker@edge \
       git \
       openssh-client

RUN npm i -g @wondermonger/version

RUN mkdir -p ~/.ssh \
    && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

COPY ./ "$CI_TOOLS_PATH"
WORKDIR "$CI_TOOLS_PATH"
RUN ./build.sh

ENV PATH "$CI_TOOLS_EXECUTABLE_PATH:$CI_TOOLS_DEPENDENCY_PATH:$PATH"

WORKDIR /
CMD ["/bin/bash"]
