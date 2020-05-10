FROM node:14-alpine

ENV CI_TOOLS_PATH "/opt/ci-tools"
ENV CI_TOOLS_EXECUTABLE_PATH "$CI_TOOLS_PATH/bin"

RUN apk update \
    && apk add --no-cache \
    bash \
    docker \
    git \
    openssh-client \
    shellcheck

RUN npm i -g @wondermonger/version

RUN mkdir -p ~/.ssh \
    && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

COPY ./ $CI_TOOLS_PATH
ENV PATH "$CI_TOOLS_EXECUTABLE_PATH:$PATH"
CMD ["/bin/bash"]
