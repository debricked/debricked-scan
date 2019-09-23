#!/usr/bin/env bats

setup() {
  DOCKER_IMAGE=${DOCKER_IMAGE:="test/debricked"}

  echo "Building image..."
  docker build -t ${DOCKER_IMAGE}:test .

  touch .env.test.local
  echo "USERNAME=$USERNAME" >> .env.test.local
  echo "PASSWORD=$PASSWORD" >> .env.test.local
  echo "BITBUCKET_REPO_OWNER=$BITBUCKET_REPO_OWNER" >> .env.test.local
  echo "BITBUCKET_REPO_SLUG=$BITBUCKET_REPO_SLUG" >> .env.test.local
  echo "BITBUCKET_COMMIT=$BITBUCKET_COMMIT" >> .env.test.local
  echo "BITBUCKET_BRANCH=$BITBUCKET_BRANCH" >> .env.test.local
}

@test "Invalid account" {
    touch .env.test
    echo "USERNAME=...foo" >> .env.test
    echo "PASSWORD=bar..." >> .env.test
    echo "BITBUCKET_REPO_OWNER=$BITBUCKET_REPO_OWNER" >> .env.test
    echo "BITBUCKET_REPO_SLUG=$BITBUCKET_REPO_SLUG" >> .env.test
    echo "BITBUCKET_COMMIT=$BITBUCKET_COMMIT" >> .env.test
    echo "BITBUCKET_BRANCH=$BITBUCKET_BRANCH" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ "$status" -eq 1 && $output =~ "Bad credentials" ]]
}

@test "Valid account, with vulnerabilities" {
    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Vulnerabilities detected" && "$status" -eq 1 ]]
}

@test "Valid account, without vulnerabilities" {
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Success! No vulnerabilities found at time time" && "$status" -eq 0 ]]
}
