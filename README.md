# GitHub Runner

[![Docker Pulls](https://img.shields.io/docker/pulls/sdigit/docker-github-runner)](https://hub.docker.com/r/sdigit/docker-github-runner)

-----------
GitHub allows developers to run GitHub Actions workflows on your own runners.
This Docker image allows you to create your own runners on Docker.

For now, there is only a Debian Buster image, but I may add more variants in the future. Feel free to create an issue if you want another base image.

## Important notes

GitHub [recommends](https://help.github.com/en/github/automating-your-workflow-with-github-actions/about-self-hosted-runners#self-hosted-runner-security-with-public-repositories) that you do **NOT** use self-hosted runners with public repositories, for security reasons.

## Usage

### Basic usage
Use the following command to start listening for jobs:
```shell
docker run -it --name my-runner \
    -e RUNNER_NAME=my-runner \
    -e GITHUB_ACCESS_TOKEN=token \
    -e RUNNER_REPOSITORY_URL=https://github.com/... \
    sdigit/github-runner
```

### Using Docker inside your Actions

If you want to use Docker inside your runner (ie, build images in a workflow), you can enable Docker siblings by binding the host Docker daemon socket. Please keep in mind that doing this gives your actions full control on the Docker daemon.

```shell
docker run -it --name my-runner \
    -e RUNNER_NAME=my-runner \
    -e GITHUB_ACCESS_TOKEN=token \
    -e RUNNER_REPOSITORY_URL=https://github.com/... \
    -v /var/run/docker.sock:/var/run/docker.sock \
    sdigit/github-runner
```

### Using docker-compose.yml

In `docker-compose.yml` :
```yaml
version: "3.7"

services:
    runner:
      image: sdigit/github-runner:latest
      environment:
        RUNNER_NAME: "my-runner"
        RUNNER_REPOSITORY_URL: ${RUNNER_REPOSITORY_URL}
        GITHUB_ACCESS_TOKEN: ${GITHUB_ACCESS_TOKEN}
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
```

You can create a `.env` to provide environment variables when using docker-compose :
```
RUNNER_REPOSITORY_URL=https://github.com/your_url/your_repo
GITHUB_ACCESS_TOKEN=the_runner_token
```

## Environment variables

The following environment variables allows you to control the configuration parameters.

| Name | Description | Default value |
|------|---------------|-------------|
| RUNNER_REPOSITORY_URL | The runner will be linked to this repository URL | Required |
| GITHUB_ACCESS_TOKEN | Personal Access Token created on [your settings page](https://github.com/settings/tokens) with `repo` scole. Used to dynamically fetch a new runner token (recommended). | Required if `RUNNER_TOKEN` is not provided.
| RUNNER_TOKEN | Runner token provided by GitHub in the Actions page. These tokens are valid for a short period. | Required if `GITHUB_ACCESS_TOKEN` is not provided
| RUNNER_WORK_DIRECTORY | Runner's work directory | `"_work"`
| RUNNER_NAME | Name of the runner displayed in the GitHub UI | Hostname of the container
| RUNNER_REPLACE_EXISTING | `"true"` will replace existing runner with the same name, `"false"` will use a random name if there is conflict | `"true"`

## Runner auto-update behavior

The GitHub runner (the binary) will update itself when receiving a job, if a new release is available.
In order to allow the runner to exit and restart by itself, the binary is started by a supervisord process.

## Runner expectations

This modified version of docker-github-runner is intended to be run under kubernetes.
It writes the acquired runner token to `/runner/token` for later use in deprovisioning.
It expects a volume mounted at `/runner` to exist, and will write its runner registration token to `/runner/token` for use in deprovisioning the runner.
