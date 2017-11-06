# CI Tools

CI/CD image and scripts for [@wondermonger](https://gitlab.com/wondermonger) projects.

## Usage

The CI/CD scripts are made available as a docker image ([wongermonger/ci-tools](https://hub.docker.com/r/wondermonger/ci-tools)) that extends [node:alpine](https://github.com/nodejs/docker-node#nodealpine).

Use it in a GitLab CI/CD Pipeline.

**Example `.gitlab-ci.yml`**

```yaml
image: wondermonger/ci-tools:latest

stages:
  - build
  - test
  - deploy

install:
  artifacts:
    paths:
      - node_modules/
  script: ci-node-install
  stage: build

lint:
  dependencies:
    - install
  script: ci-node-lint
  stage: test

unit:
  dependencies:
    - install
  script: ci-node-unit-tests
  stage: test

integration:
  dependencies:
    - install
  script: ci-node-integration-tests
  stage: test

release:
  dependencies:
    - install
  only:
    - master
  script:
    - ci-git-config
    - ci-git-node-release
  stage: deploy

publish:
  dependencies:
    - install
  only:
    - tags
  script: ci-node-publish
  stage: deploy

```

**Example `docker run`**

```shell
docker run \
  -e ACCESS_EMAIL \
  -e ACCESS_NAME \
  -e CI_COMMIT_REF_NAME \
  -e CI_PROJECT_PATH \
  -e SSH_PRIVATE_KEY \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  -v "$(pwd):/usr/local/my-project" \
  -w "/usr/local/my-project" \
  wondermonger/ci-tools:latest \
  /bin/bash -c "ci-git-config && ci-git-shell-release"

```

## CI/CD Scripts

```shell
# docker
ci-docker-build
ci-docker-login
ci-docker-push

# git
ci-git-config
ci-git-node-release
ci-git-shell-release

# node.js
ci-node-auth-token
ci-node-install
ci-node-integration-tests
ci-node-lint
ci-node-publish
ci-node-tests
ci-node-unit-tests

# shell script
ci-shell-lint

```

## Environment Variables

| Variable              | Description                              | Required By                              |
| --------------------- | ---------------------------------------- | ---------------------------------------- |
| `CI_COMMIT_TAG`*      | Version Tag                              | `ci-docker-build`                        |
| `CI_COMMIT_REF_NAME`* | Branch or Tag Name                       | `ci-git-node-release` `ci-git-shell-release` |
| `CI_PROJECT_NAME`*    | Name of Project                          | `ci-docker-build` `ci-docker-push`       |
| `CI_PROJECT_PATH`*    | Namespace and Project Name               | `ci-git-node-release` `ci-git-shell-release` |
| `DOCKER_ORGANIZATION` | Name of Docker Organization              | `ci-docker-build` `ci-docker-push`       |
| `DOCKER_PASSWORD`     | Docker Password                          | `ci-docker-login`                        |
| `DOCKER_USERNAME`     | Docker Username                          | `ci-docker-login`                        |
| `GIT_USER_EMAIL`      | Git User Email                           | `ci-git-config`                          |
| `GIT_USER_NAME`       | Git User Name                            | `ci-git-config`                          |
| `NPM_TOKEN`           | NPM Token for Publishing Project Package | `ci-node-auth-token` `ci-node-publish`   |
| `SSH_PRIVATE_KEY`     | Private SSH Key for Pushing Git Commits  | `ci-git-node-release` `ci-git-shell-release` |

\* these variables are predefined if you are using GitLab CI

## License

The MIT License (MIT)

Copyright (c) 2017 Michael J. Bondra <mjbondra@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
