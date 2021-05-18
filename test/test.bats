#!/usr/bin/env bats

setup() {
  DOCKER_IMAGE=${DOCKER_IMAGE:="test/debricked"}

  echo "Building image..."
  docker build -t ${DOCKER_IMAGE}:test .

  random_hash=$(openssl rand -hex 20)

  touch .env.test.local
  echo "USERNAME=$USERNAME" > .env.test.local
  echo "PASSWORD=$PASSWORD" >> .env.test.local
  echo "BITBUCKET_REPO_OWNER=$BITBUCKET_REPO_OWNER" >> .env.test.local
  echo "BITBUCKET_REPO_SLUG=$BITBUCKET_REPO_SLUG" >> .env.test.local
  echo "BITBUCKET_GIT_HTTP_ORIGIN=$BITBUCKET_GIT_HTTP_ORIGIN" >> .env.test.local
  echo "BITBUCKET_COMMIT=$random_hash" >> .env.test.local
}

@test "Invalid account" {
    touch .env.test
    echo "USERNAME=...foo" > .env.test
    echo "PASSWORD=bar..." >> .env.test
    echo "BITBUCKET_REPO_OWNER=$BITBUCKET_REPO_OWNER" >> .env.test
    echo "BITBUCKET_REPO_SLUG=$BITBUCKET_REPO_SLUG" >> .env.test
    echo "BITBUCKET_GIT_HTTP_ORIGIN=$BITBUCKET_GIT_HTTP_ORIGIN" >> .env.test
    echo "BITBUCKET_COMMIT=$BITBUCKET_COMMIT" >> .env.test
    echo "BITBUCKET_BRANCH=$BITBUCKET_BRANCH" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ "$status" -eq 1 && $output =~ "Invalid credentials." ]]
}

@test "Valid account, with vulnerabilities" {
    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "VULNERABILITIES FOUND" && "$status" -eq 0 && $output =~ "upload-all-files" ]]
}

@test "Valid account, with vulnerabilities, enabled upload-all-files option" {
    echo "UPLOAD_ALL_FILES=true" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "VULNERABILITIES FOUND" && "$status" -eq 0 && ! $output =~ "\supload-all-files\s+option" ]]
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

    [[ $output =~ "Success! No vulnerabilities found at this time" && "$status" -eq 0 && $output != *"upload-all-files"* ]]
}

#@test "Valid account, without vulnerabilities, without Gradle files, pipeline warning" {
#    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local
#    echo "BITBUCKET_REPO_SLUG=${BITBUCKET_REPO_SLUG}-pipeline-warning-no-vuln" >> .env.test.local
#
#    run docker run \
#        --env-file ./.env.test.local \
#        -v $(pwd):$(pwd) \
#        -w $(pwd) \
#        ${DOCKER_IMAGE}:test
#
#    echo "Status: $status"
#    echo "Output: $output"
#
#    [[ $output =~ "No vulnerabilities found at this time.\s+A policy engine rule triggered a pipeline warning, please view output above for more details" && "$status" -eq 0 && $output != *"upload-all-files"* ]]
#}

#@test "Valid account, with vulnerabilities, without Gradle files, pipeline warning" {
#    echo "BITBUCKET_REPO_SLUG=${BITBUCKET_REPO_SLUG}-pipeline-warning-with-vuln" >> .env.test.local
#
#    run docker run \
#        --env-file ./.env.test.local \
#        -v $(pwd):$(pwd) \
#        -w $(pwd) \
#        ${DOCKER_IMAGE}:test
#
#    echo "Status: $status"
#    echo "Output: $output"
#
#    [[ $output =~ "VULNERABILITIES FOUND\s+A policy engine rule triggered a pipeline warning, please view output above for more details" && "$status" -eq 0 && $output != *"upload-all-files"* ]]
#}

#@test "Valid account, without vulnerabilities, without Gradle files, pipeline failure" {
#    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local
#    echo "BITBUCKET_REPO_SLUG=${BITBUCKET_REPO_SLUG}-pipeline-failure-no-vuln" >> .env.test.local
#
#    run docker run \
#        --env-file ./.env.test.local \
#        -v $(pwd):$(pwd) \
#        -w $(pwd) \
#        ${DOCKER_IMAGE}:test
#
#    echo "Status: $status"
#    echo "Output: $output"
#
#    [[ $output =~ "No vulnerabilities found at this time.\s+A policy engine rule triggered a pipeline failure, please view output above for more details" && "$status" -eq 0 && $output != *"upload-all-files"* ]]
#}

#@test "Valid account, with vulnerabilities, without Gradle files, pipeline failure" {
#    echo "BITBUCKET_REPO_SLUG=${BITBUCKET_REPO_SLUG}-pipeline-failure-with-vuln" >> .env.test.local
#
#    run docker run \
#        --env-file ./.env.test.local \
#        -v $(pwd):$(pwd) \
#        -w $(pwd) \
#        ${DOCKER_IMAGE}:test
#
#    echo "Status: $status"
#    echo "Output: $output"
#
#    [[ $output =~ "VULNERABILITIES FOUND\s+A policy engine rule triggered a pipeline failure, please view output above for more details" && "$status" -eq 0 && $output != *"upload-all-files"* ]]
#}

@test "Valid account, skip scan true" {
    echo "SKIP_SCAN=true" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Files were successfully uploaded, scan result will be available at" && "SKIP_SCAN = $SKIP_SCAN"  && "$status" -eq 0 ]]
}

@test "Valid account, skip scan false" {
    echo "SKIP_SCAN=false" >> .env.test.local
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Success! No vulnerabilities found at this time" && "SKIP_SCAN = $SKIP_SCAN"  && "$status" -eq 0 ]]
}

@test "Valid account, with branch, with vulnerabilities" {
    echo "BITBUCKET_BRANCH=$BITBUCKET_BRANCH" >> .env.test.local
    
    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "VULNERABILITIES FOUND" && "$status" -eq 0 ]]
}

@test "Valid account, with branch, without vulnerabilities" {
    echo "BITBUCKET_BRANCH=$BITBUCKET_BRANCH" >> .env.test.local
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Success! No vulnerabilities found at this time" && "$status" -eq 0 ]]
}

@test "Disable snippet scan does indeed disable snippet scan" {
    echo "DISABLE_SNIPPET_SCAN=true" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "--disable-snippets" && "$status" -eq 0 ]]
}

@test "Can handle repos with space in name" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "USERNAME=$USERNAME" > .env.test
    echo "PASSWORD=$PASSWORD" >> .env.test
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

    [[ $output =~ "Success! No vulnerabilities found at this time" && "$status" -eq 0 && $output != *"upload-all-files"* ]]
}

@test "CircleCI Github unknown repo url" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "CIRCLE_PROJECT_USERNAME=someuser" >> .env.test
    echo "CIRCLE_PROJECT_REPONAME=somerepo" >> .env.test
    echo "CIRCLE_REPOSITORY_URL=git@someweirdhost.com:someuser/somerepo.git" >> .env.test
    echo "CIRCLE_BRANCH=main" >> .env.test
    echo "CIRCLE_SHA1=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /circleci.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Your repository URL could not be found" && "$status" -eq 0 ]]
}

@test "CircleCI Github repourl override" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "CIRCLE_PROJECT_USERNAME=someuser" >> .env.test
    echo "CIRCLE_PROJECT_REPONAME=somerepo" >> .env.test
    echo "CIRCLE_REPOSITORY_URL=git@github.com:someuser/somerepo.git" >> .env.test
    echo "CIRCLE_BRANCH=main" >> .env.test
    echo "CIRCLE_SHA1=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test
    echo "DEBRICKED_REPOSITORY_URL=https://some.git.host/location/here" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /circleci.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "https://some.git.host/location/here" && "$status" -eq 0 ]]
}

@test "CircleCI Github SSH repo parsing" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "CIRCLE_PROJECT_USERNAME=someuser" >> .env.test
    echo "CIRCLE_PROJECT_REPONAME=repo-is_her3" >> .env.test
    echo "CIRCLE_REPOSITORY_URL=git@github.com:someuser/repo-is_her3.git" >> .env.test
    echo "CIRCLE_BRANCH=main" >> .env.test
    echo "CIRCLE_SHA1=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /circleci.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "https://github.com/someuser/repo-is_her3" && "$status" -eq 0 ]]
}
