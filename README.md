# CI Tools

CI/CD image, scripts, and templates for [@wondermonger](https://gitlab.com/wondermonger) projects.

## Usage

The CI/CD scripts are made available as a docker image ([wongermonger/ci-tools](https://hub.docker.com/r/wondermonger/ci-tools)) that extends [node:alpine](https://github.com/nodejs/docker-node#nodealpine).

Use it in a GitLab CI/CD Pipeline.

**Example `.gitlab-ci.yml`**

```yaml
include:
  - https://gitlab.com/wondermonger/ci-tools/raw/v5.1.0/tpl/node/base.yml
  - https://gitlab.com/wondermonger/ci-tools/raw/v5.1.0/tpl/node/post-install/lint.yml
  - https://gitlab.com/wondermonger/ci-tools/raw/v5.1.0/tpl/node/test/simple.yml
  - https://gitlab.com/wondermonger/ci-tools/raw/v5.1.0/tpl/node/test/coverage.yml
  - https://gitlab.com/wondermonger/ci-tools/raw/v5.1.0/tpl/node/build/public.yml
  - https://gitlab.com/wondermonger/ci-tools/raw/v5.1.0/tpl/node/post-build/pages.yml
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

**Available Images**

| Tag Pattern  | Description                                                | Examples                                |
| ------------ | ---------------------------------------------------------- | --------------------------------------- |
| `latest`     | Latest Release                                             | `latest`                                |
| `vX`         | Latest Minor or Patch Release Within a Given Major Version | `v5`                                    |
| `vX.Y`       | Latest Patch Release Within a Given Minor Version          | `v5.0` `v5.1`                           |
| `vX.Y.Z`     | Specific Patch Release                                     | `v5.0.0` `v5.1.0` `v5.1.1`              |
| `vX.Y.Z-A`\* | Specific Prerelease                                        | `v5.0.0-0` `v5.1.0-alpha` `v5.1.1-beta` |

\* if prereleases are published, they should not be used for anything other than development

## CI/CD Scripts

- **Docker**
  - [ci-docker-build](#ci-docker-build)
  - [ci-docker-config](#ci-docker-config)
  - [ci-docker-release](#ci-docker-release)
- **Git**
  - [ci-git-config](#ci-git-config)
  - [ci-git-release](#ci-git-release-a-artifact-t-type)
- **Node**
  - [ci-node-config](#ci-node-config)
  - [ci-node-release](#ci-node-release)
- **Shell**
  - [ci-shell-lint](#ci-shell-lint)

### `ci-docker-build`

**Description:** Builds and tags a docker image from the current working directory.

**Prerequisites:** None

**[Environment Variables](#environment-variables):** `CI_COMMIT_TAG` `CI_PROJECT_NAME` `DOCKER_ORGANIZATION`

**Arguments:** None

### `ci-docker-config`

**Description:** Establishes a session with the Docker registry.

**Prerequisites:** None

**[Environment Variables](#environment-variables):** `DOCKER_PASSWORD` `DOCKER_USERNAME`

**Arguments:** None

### `ci-docker-release`

**Description:** Publishes an image to the Docker registry.

**Prerequisites:** [`ci-docker-config`](#ci-docker-config)

**[Environment Variables](#environment-variables):** `CI_PROJECT_NAME` `DOCKER_ORGANIZATION`

**Arguments:** None

### `ci-git-config`

**Description:** Configures global user name and email for git.

**Prerequisites:** None

**[Environment Variables](#environment-variables):** `GIT_USER_EMAIL` `GIT_USER_NAME`

**Arguments:** None

### `ci-git-release [-a <artifact>] [-t <type>]`

**Description:** Creates and pushes a tagged git release.

**Prerequisites:** [`ci-git-config`](#ci-git-config)

**[Environment Variables](#environment-variables):** `CI_PROJECT_PATH` `CI_COMMIT_REF_NAME` `SSH_PRIVATE_KEY`

**Arguments:**

- **`-a` :** path to uncommitted **artifact(s)** that should be included in the release
  - use the `-a` flag multiple times to specify multiple artifacts
  - **Example:** `ci-git-release -a lib -a bin`
- **`-t` :** **type** of release
  - either `node` for node projects, or `shell` for everything else
  - default value is `node`

### `ci-node-config`

**Description:** Specifies an auth token to use for publishing packages to the default npm registry.

**Prerequisites:** None

**[Environment Variables](#environment-variables):** `NPM_TOKEN`

**Arguments:** None

### `ci-node-release`

**Description:** Publishes a package to the default npm registry.

**Prerequisites:** [`ci-node-config`](#ci-node-config)

**[Environment Variables](#environment-variables):** None

**Arguments:** None

### `ci-shell-lint`

**Description:** Executes [`shellcheck`](https://github.com/koalaman/shellcheck) against all shell scripts in a given project.

**Prerequisites:** None

**[Environment Variables](#environment-variables):** None

**Arguments:** None

## Environment Variables

| Variable               | Description                              | Required By                           |
| ---------------------- | ---------------------------------------- | ------------------------------------- |
| `CI_COMMIT_TAG`\*      | Version Tag                              | `ci-docker-build`                     |
| `CI_COMMIT_REF_NAME`\* | Branch or Tag Name                       | `ci-git-release`                      |
| `CI_PROJECT_NAME`\*    | Name of Project                          | `ci-docker-build` `ci-docker-release` |
| `CI_PROJECT_PATH`\*    | Namespace and Project Name               | `ci-git-release`                      |
| `DOCKER_ORGANIZATION`  | Name of Docker Organization              | `ci-docker-build` `ci-docker-release` |
| `DOCKER_PASSWORD`      | Docker Password                          | `ci-docker-config`                    |
| `DOCKER_USERNAME`      | Docker Username                          | `ci-docker-config`                    |
| `GIT_USER_EMAIL`       | Git User Email                           | `ci-git-config`                       |
| `GIT_USER_NAME`        | Git User Name                            | `ci-git-config`                       |
| `NPM_TOKEN`            | NPM Token for Publishing Project Package | `ci-node-config`                      |
| `SSH_PRIVATE_KEY`      | Private SSH Key for Pushing Git Commits  | `ci-git-release`                      |

\* these variables are predefined if you are using GitLab CI

## Templates

When including the templates listed below, versioned templates should be preferred over latest.

**PREFERRED**: https://gitlab.com/wondermonger/ci-tools/raw/v5.1.0/tpl/node/base.yml

**LATEST**: https://gitlab.com/wondermonger/ci-tools/raw/master/tpl/node/base.yml

| URL                                                                                | Description                                                                                                                                                                      |
| ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| https://gitlab.com/wondermonger/ci-tools/raw/master/tpl/node/base.yml              | Base template for Node.js projects that provides installation, dependency auditing, outdated dependency notification, patch versioning, git release tagging, and npm publishing. |
| https://gitlab.com/wondermonger/ci-tools/raw/master/tpl/node/post-install/lint.yml | Invokes `npm run lint` during the `post-install` stage.                                                                                                                          |
| https://gitlab.com/wondermonger/ci-tools/raw/master/tpl/node/test/simple.yml       | Invokes `npm test` during the `test` stage.                                                                                                                                      |
| https://gitlab.com/wondermonger/ci-tools/raw/master/tpl/node/test/expanded.yml     | Invokes `npm run test:integration` and `npm run test:unit` during the `test` stage.                                                                                              |
| https://gitlab.com/wondermonger/ci-tools/raw/master/tpl/node/test/coverage.yml     | Invokes `npm run test:coverage` and extracts coverage data during the `test` stage. This template will persist artifacts created in the `./public/coverage` directory.           |
| https://gitlab.com/wondermonger/ci-tools/raw/master/tpl/node/build/dist.yml        | Invokes `npm run build` during the `build` stage. This template will persist artifacts created in the `./dist` directory.                                                        |
| https://gitlab.com/wondermonger/ci-tools/raw/master/tpl/node/build/public.yml      | Invokes `npm run build` during the `build` stage. This template will persist artifacts created in the `./public` directory.                                                      |
| https://gitlab.com/wondermonger/ci-tools/raw/master/tpl/node/post-build/pages.yml  | A generic GitLab pages job executed during the `post-build` stage.                                                                                                               |

## License

The MIT License (MIT)

Copyright (c) 2017-2019 Michael J. Bondra <mjbondra@gmail.com>

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
