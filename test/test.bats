#!/usr/bin/env bats

setup() {
  DOCKER_IMAGE=${DOCKER_IMAGE:="test/debricked"}

  echo "Building image..."
  docker build -t ${DOCKER_IMAGE}:test .

  random_hash=$(openssl rand -hex 20)

  touch .env.test.local
  echo "DEBRICKED_TOKEN=$DEBRICKED_TOKEN" > .env.test.local
  echo "BITBUCKET_REPO_OWNER=$BITBUCKET_REPO_OWNER" >> .env.test.local
  echo "BITBUCKET_REPO_SLUG=$BITBUCKET_REPO_SLUG" >> .env.test.local
  echo "BITBUCKET_GIT_HTTP_ORIGIN=$BITBUCKET_GIT_HTTP_ORIGIN" >> .env.test.local
  echo "BITBUCKET_COMMIT=$random_hash" >> .env.test.local
}

@test "Valid account, with vulnerabilities" {
    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " vulnerabilities found" && $output =~ "Vulnerabilities:" && "$status" -eq 0 ]]
}

@test "Valid account, without vulnerabilities, without Gradle files" {
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "0 vulnerabilities found" && "$status" -eq 0 ]]
}

@test "Valid account, without vulnerabilities, without Gradle files, pipeline warning" {
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local
    echo "BITBUCKET_REPO_SLUG=${BITBUCKET_REPO_SLUG}-pipeline-warning-no-vuln" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "0 vulnerabilities found" && $output =~ "acorn (npm)" ]]
}

@test "Valid account, with vulnerabilities, without Gradle files, pipeline warning" {
    echo "BITBUCKET_REPO_SLUG=${BITBUCKET_REPO_SLUG}-pipeline-warning-with-vuln" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "vulnerabilities found" && $output =~ "Vulnerabilities:" ]]
}

@test "Valid account, without vulnerabilities, without Gradle files, pipeline failure" {
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local
    echo "BITBUCKET_REPO_SLUG=${BITBUCKET_REPO_SLUG}-pipeline-failure-no-vuln" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "0 vulnerabilities found" && $output =~ "acorn (npm)" ]]
}

@test "Valid account, with vulnerabilities, without Gradle files, pipeline failure" {
    echo "BITBUCKET_REPO_SLUG=${BITBUCKET_REPO_SLUG}-pipeline-failure-with-vuln" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "vulnerabilities found" && $output =~ "Vulnerabilities:" ]]
}

@test "Can handle repos with space in name" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_TOKEN=$DEBRICKED_TOKEN" > .env.test
    echo "BITBUCKET_REPO_OWNER=$BITBUCKET_REPO_OWNER" >> .env.test

    # make a repo with space in name here.
    echo 'BITBUCKET_REPO_SLUG="space repo"' >> .env.test

    echo "BITBUCKET_GIT_HTTP_ORIGIN=$BITBUCKET_GIT_HTTP_ORIGIN" >> .env.test
    echo "BITBUCKET_COMMIT=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "0 vulnerabilities found" && "$status" -eq 0 ]]
}

@test "Invalid access token" {
    echo "DEBRICKED_TOKEN=abcdef1234567890" > .env.test
    echo "BITBUCKET_REPO_OWNER=$BITBUCKET_REPO_OWNER" >> .env.test
    echo "BITBUCKET_REPO_SLUG=$BITBUCKET_REPO_SLUG" >> .env.test
    echo "BITBUCKET_GIT_HTTP_ORIGIN=$BITBUCKET_GIT_HTTP_ORIGIN" >> .env.test
    echo "BITBUCKET_COMMIT=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ "$status" -eq 1 && $output =~ "Unauthorized. Specify access token." ]]
}
