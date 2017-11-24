# CI Tools

CI/CD image and scripts for [@wondermonger](https://gitlab.com/wondermonger) projects.

## Usage

The CI/CD scripts are made available as a docker image ([wongermonger/ci-tools](https://hub.docker.com/r/wondermonger/ci-tools)) that extends [node:alpine](https://github.com/nodejs/docker-node#nodealpine).

Use it in a GitLab CI/CD Pipeline.

**Example `.gitlab-ci.yml`**

```yaml
image: wondermonger/ci-tools:latest

stages:
  - install
  - lint
  - build
  - test
  - deploy

install:
  artifacts:
    paths:
      - node_modules/
  script: ci-node-install
  stage: install

lint:
  script: ci-node-lint
  stage: lint

documentation:
  artifacts:
    paths:
      - docs/rules/
  script: ci-node-build docs
  stage: build

unit:
  script: ci-node-test unit
  stage: test

integration:
  script: ci-node-test integration
  stage: test

release:
  only:
    - master
  script:
    - ci-git-config
    - ci-git-release -a docs/rules
  stage: deploy

publish:
  only:
    - tags
  script:
  	- ci-node-config
  	- ci-node-release
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
  /bin/bash -c "ci-git-config && ci-git-release -t shell -a lib -a bin"

```

## CI/CD Scripts

- **Docker**
  - [ci-docker-build](#ci-docker-build)
  - [ci-docker-config](#ci-docker-config)
  - [ci-docker-release](#ci-docker-release)
- **Git**
  - [ci-git-config](#ci-git-config)
  - [ci-git-release](#ci-git-release-a-artifact-path-t-nodeshell)
- **Node**
  - [ci-node-build](#ci-node-build-subtask)
  - [ci-node-config](#ci-node-config)
  - [ci-node-install](#ci-node-install)
  - [ci-node-lint](#ci-node-lint-subtask)
  - [ci-node-release](#ci-node-release)
  - [ci-node-test](#ci-node-test-subtask)
- **Shell**
  - [ci-shell-lint](#ci-shell-lint)

### `ci-docker-build`

**Description:** Builds and tags a docker image from the current working directory.

**Prerequisites:** None

[**Environment Variables:**](#environment-variables) `CI_COMMIT_TAG` `CI_PROJECT_NAME` `DOCKER_ORGANIZATION`

**Arguments:** None

### `ci-docker-config`

**Description:** Establishes a session with the Docker registry.

**Prerequisites:** None

[**Environment Variables:**](#environment-variables) `DOCKER_PASSWORD` `DOCKER_USERNAME`

**Arguments:** None

### `ci-docker-release`

**Description:** Publishes an image to the Docker registry.

**Prerequisites:** [`ci-docker-config`](#ci-docker-config)

[**Environment Variables:**](#environment-variables) `CI_PROJECT_NAME` `DOCKER_ORGANIZATION`

**Arguments:** None

### `ci-git-config`

**Description:** Configures user name, user email, and SSH access for git.

**Prerequisites:** None

[**Environment Variables:**](#environment-variables) `GIT_USER_EMAIL` `GIT_USER_NAME` `SSH_PRIVATE_KEY`

**Arguments:** None

### `ci-git-release [-a <artifact path>] [-t <node|shell>]`

**Description:** Creates and pushes a tagged git release.

**Prerequisites:** [`ci-git-config`](#ci-git-config)

[**Environment Variables:**](#environment-variables) `CI_PROJECT_PATH` `CI_COMMIT_REF_NAME`

**Arguments:**

- **`-a` :** path to uncommitted **artifact(s)** that should be included in the release
  - use the `-a` flag multiple times to specify multiple artifacts
  - **Example:** `ci-git-release -a lib -a bin`
- **`-t` :** **type** of release
  - either `node` for node projects, or `shell` for everything else
  - default value is `node`

### `ci-node-build [<subtask>]`

**Description:** Executes the `build` script specified in `package.json`.

**Prerequisites:** [`ci-node-install`](#ci-node-install)

[**Environment Variables:**](#environment-variables) None

**Arguments:**

- **`<subtask>` :** optional script execution modifier
  - Executes a script called `build:<subtask>` specified in `package.json`
  - **Example:** `ci-node-build docs` executes `build:docs`

### `ci-node-config`

**Description:** Specifies an auth token to use for publishing packages to the default npm registry.

**Prerequisites:** None

[**Environment Variables:**](#environment-variables) `NPM_TOKEN`

**Arguments:** None

### `ci-node-install`

**Description:** Executes `yarn` to install package dependencies.

**Prerequisites:** None

[**Environment Variables:**](#environment-variables) None

**Arguments:** None

### `ci-node-lint [<subtask>]`

**Description:** Executes the `lint` script specified in `package.json`.

**Prerequisites:** [`ci-node-install`](#ci-node-install)

[**Environment Variables:**](#environment-variables) None

**Arguments:**

- **`<subtask>` :** optional script execution modifier
  - Executes a script called `lint:<subtask>` specified in `package.json`
  - **Example:** `ci-node-build lib` executes `lint:lib`

### `ci-node-release`

**Description:** Publishes a package to the default npm registry.

**Prerequisites:** [`ci-node-config`](#ci-node-config)

[**Environment Variables:**](#environment-variables) None

**Arguments:** None

### `ci-node-test [<subtask>]`

**Description:** Executes the `test` script specified in `package.json`.

**Prerequisites:** [`ci-node-install`](#ci-node-install)

[**Environment Variables:**](#environment-variables) None

**Arguments:**

- **`<subtask>` :** optional script execution modifier
  - Executes a script called `test:<subtask>` specified in `package.json`
  - **Example:** `ci-node-build unit` executes `test:unit`

### `ci-shell-lint`

**Description:** Executes [`shellcheck`](https://github.com/koalaman/shellcheck) against all shell scripts in a given project.

**Prerequisites:** None

[**Environment Variables:**](#environment-variables) None

**Arguments:** None

## Environment Variables

| Variable              | Description                              | Required By                           |
| --------------------- | ---------------------------------------- | ------------------------------------- |
| `CI_COMMIT_TAG`*      | Version Tag                              | `ci-docker-build`                     |
| `CI_COMMIT_REF_NAME`* | Branch or Tag Name                       | `ci-git-release`                      |
| `CI_PROJECT_NAME`*    | Name of Project                          | `ci-docker-build` `ci-docker-release` |
| `CI_PROJECT_PATH`*    | Namespace and Project Name               | `ci-git-release`                      |
| `DOCKER_ORGANIZATION` | Name of Docker Organization              | `ci-docker-build` `ci-docker-release` |
| `DOCKER_PASSWORD`     | Docker Password                          | `ci-docker-config`                    |
| `DOCKER_USERNAME`     | Docker Username                          | `ci-docker-config`                    |
| `GIT_USER_EMAIL`      | Git User Email                           | `ci-git-config`                       |
| `GIT_USER_NAME`       | Git User Name                            | `ci-git-config`                       |
| `NPM_TOKEN`           | NPM Token for Publishing Project Package | `ci-node-config`                      |
| `SSH_PRIVATE_KEY`     | Private SSH Key for Pushing Git Commits  | `ci-git-config`                       |

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
