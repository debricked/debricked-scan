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
  echo "DISABLE_CONDITIONAL_SKIP_SCAN=true" >> .env.test.local
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

    [[ $output =~ "VULNERABILITIES FOUND" && "$status" -eq 0 ]]
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

    [[ $output =~ "VULNERABILITIES FOUND" && "$status" -eq 0 && ! $output =~ "\supload-all-files\s+option" && $output =~ "Vulnerabilities detected." ]]
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

    [[ $output =~ "No vulnerabilities found at this time." && $output =~ "An automation rule triggered a pipeline warning, please view output above for more details" && "$status" -eq 0 && $output != *"upload-all-files"* ]]
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

    [[ $output =~ "VULNERABILITIES FOUND" && $output =~ "Vulnerabilities detected." && $output =~ "An automation rule triggered a pipeline warning, please view output above for more details" && "$status" -eq 0 ]]
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

    [[ $output =~ "No vulnerabilities found at this time." && $output =~ "An automation rule triggered a pipeline failure, please view output above for more details" && "$status" -eq 1 && $output != *"upload-all-files"* ]]
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

    [[ $output =~ "VULNERABILITIES FOUND" && $output =~ "Vulnerabilities detected." && $output =~ "An automation rule triggered a pipeline failure, please view output above for more details" && "$status" -eq 1 ]]
}

@test "Valid account, skip scan true" {
    echo "DISABLE_CONDITIONAL_SKIP_SCAN=false" >> .env.test.local
    echo "SKIP_SCAN=true" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Files were successfully uploaded, scan result will be available at" && $output != *"VULNERABILITIES FOUND"* && "SKIP_SCAN = $SKIP_SCAN"  && "$status" -eq 0 ]]
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

    [[ $output =~ "VULNERABILITIES FOUND" && $output =~ "An automation rule triggered a pipeline warning, please view output above for more details" && "$status" -eq 0 && $output =~ "Vulnerabilities detected." ]]
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

@test "Enable snippet analysis does indeed enable snippet analysis" {
    echo "SNIPPET_ANALYSIS=true" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "--snippet-analysis" && "$status" -eq 0 ]]
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

@test "Access token instead of username and password" {
    echo "DEBRICKED_TOKEN=$DEBRICKED_TOKEN" > .env.test
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

    [[ $output =~ "Success! No vulnerabilities found at this time" && "$status" -eq 0 && $output != *"upload-all-files"* ]]
}

@test "Access token is used if token and username and password are given all at once" {
    echo "DEBRICKED_TOKEN=$DEBRICKED_TOKEN" > .env.test
    echo "USERNAME=some-really-invalid-user@example.com" >> .env.test
    echo "PASSWORD=just-wrong" >> .env.test
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

    [[ $output =~ "Success! No vulnerabilities found at this time" && "$status" -eq 0 && $output != *"upload-all-files"* ]]
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

    [[ "$status" -eq 1 && $output =~ "An authentication exception occurred" ]]
}

@test "Gitlab has no default branch" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "USERNAME=$USERNAME" > .env.test
    echo "PASSWORD=$PASSWORD" >> .env.test
    echo "CI_PROJECT_PATH=someuser/repo-is_her3" >> .env.test
    echo "CI_PROJECT_URL=git@gitlab.com:someuser/repo-is_her3.git" >> .env.test
    echo "CI_COMMIT_REF_NAME=main" >> .env.test
    echo "CI_COMMIT_SHA=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /gitlab-ci.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "You are probably using a version of gitlab before 12.4. This means we can not know what your default branch is. This might impact your experience using Debricked's tools" && "$status" -eq 0 ]]
}

@test "Gitlab has default branch" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "USERNAME=$USERNAME" > .env.test
    echo "PASSWORD=$PASSWORD" >> .env.test
    echo "CI_PROJECT_PATH=someuser/repo-is_her3" >> .env.test
    echo "CI_PROJECT_URL=git@gitlab.com:someuser/repo-is_her3.git" >> .env.test
    echo "CI_COMMIT_REF_NAME=main" >> .env.test
    echo "CI_COMMIT_SHA=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test
    echo "CI_DEFAULT_BRANCH=dev" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /gitlab-ci.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Success! No vulnerabilities found at this time" && "$status" -eq 0 ]]
}

@test "Disable conditional skip scan false and skip scan false" {
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local
    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output != *"Files were successfully uploaded, scan result will be available at"* && $output =~ "Success! No vulnerabilities found at this time" && "$status" -eq 0 ]]
}

@test "Disable conditional skip scan false and skip scan true" {
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local
    echo "SKIP_SCAN=true" >> .env.test.local
    echo "DISABLE_CONDITIONAL_SKIP_SCAN=false" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Files were successfully uploaded, scan result will be available at" && $output != *"Success! No vulnerabilities found at this time"* && "$status" -eq 0 ]]
}

@test "Disable conditional skip scan true and skip scan false" {
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local
    echo "DISABLE_CONDITIONAL_SKIP_SCAN=true" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output != *"Files were successfully uploaded, scan result will be available at"* && $output =~ "Success! No vulnerabilities found at this time" && "$status" -eq 0 ]]
}

@test "Disable conditional skip scan true and skip scan true" {
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test.local
    echo "SKIP_SCAN=true" >> .env.test.local

    run docker run \
        --env-file ./.env.test.local \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output != *"Files were successfully uploaded, scan result will be available at"* && $output =~ "Success! No vulnerabilities found at this time" && "$status" -eq 0 ]]
}

@test "BuildKite Github unknown repo url" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "BUILDKITE_REPO=test-repo-name" >> .env.test
    echo "BUILDKITE_BRANCH=main" >> .env.test
    echo "BUILDKITE_COMMIT=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /buildkite.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " test-repo-name " && $output =~ "Your repository URL could not be found" && "$status" -eq 0 ]]
}

@test "BuildKite Github repourl override" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "BUILDKITE_REPO=test-repo-name" >> .env.test
    echo "BUILDKITE_BRANCH=main" >> .env.test
    echo "BUILDKITE_COMMIT=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test
    echo "DEBRICKED_REPOSITORY_URL=https://some.git.host/location/here" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /buildkite.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " test-repo-name " && $output =~ "https://some.git.host/location/here" && "$status" -eq 0 ]]
}

@test "BuildKite Github SSH repo parsing" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "BUILDKITE_REPO=git@gitlab.com:1337/someuser/repo-is_her3.git" >> .env.test
    echo "BUILDKITE_BRANCH=main" >> .env.test
    echo "BUILDKITE_COMMIT=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /buildkite.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " someuser/repo-is_her3 " && $output =~ "https://gitlab.com/someuser/repo-is_her3" && "$status" -eq 0 ]]
}

@test "BuildKite Github https repo parsing" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "BUILDKITE_REPO=https://some.git.host/someuser/repo-is_her3.git" >> .env.test
    echo "BUILDKITE_BRANCH=main" >> .env.test
    echo "BUILDKITE_COMMIT=$random_hash" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /buildkite.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " someuser/repo-is_her3 " && $output =~ "https://some.git.host/someuser/repo-is_her3" && "$status" -eq 0 ]]
}

@test "Argo Workflows missing DEBRICKED_GIT_URL" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "DEBRICKED_GIT_URL=''" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /argo.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Your repository URL could not be found. Set it manually with DEBRICKED_REPOSITORY_URL" && "$status" -eq 0 ]]
}

@test "Argo Workflows Github unknown repo url" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "DEBRICKED_GIT_URL=test-repo-name-url" >> .env.test
    echo "REPOSITORY=test-repo-name" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /argo.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " test-repo-name " && $output =~ "Your repository URL could not be found" && "$status" -eq 0 ]]
}

@test "Argo Workflows Github repourl override" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "DEBRICKED_GIT_URL=https://github.com/location/here.git" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test
    echo "DEBRICKED_REPOSITORY_URL=https://some.git.host/location/here" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /argo.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " location/here " && $output =~ "https://some.git.host/location/here" && "$status" -eq 0 ]]
}

@test "Argo Workflows Github SSH repo parsing" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "DEBRICKED_GIT_URL=git@gitlab.com:1337/someuser/repo-is_her3.git" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /argo.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " someuser/repo-is_her3 " && $output =~ "https://gitlab.com/someuser/repo-is_her3" && "$status" -eq 0 ]]
}

@test "Argo Workflows Github https repo parsing" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "DEBRICKED_GIT_URL=https://some.git.host/someuser/repo-is_her3.git" >> .env.test
    echo "BASE_DIRECTORY=/test/not-vulnerable" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        --entrypoint /argo.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " someuser/repo-is_her3 " && $output =~ "https://some.git.host/someuser/repo-is_her3" && "$status" -eq 0 ]]
}

@test "Argo Workflows missing git repo with commit variable" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "COMMIT=test-commit" >> .env.test
    echo "DEBRICKED_GIT_URL=https://some.git.host/someuser/repo-is_her3.git" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w /root \
        --entrypoint /argo.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " test-commit " && $output =~ "Repository branch could not be found" && $output =~ "Commit-author could not be found" && "$status" -eq 0 ]]
}

@test "Argo Workflows missing git repo and variables" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "DEBRICKED_GIT_URL=https://some.git.host/someuser/repo-is_her3.git" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w /root \
        --entrypoint /argo.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ "Commit could not be found" && "$status" -eq 1 ]]
}

@test "Argo Workflows missing git repo all variables set" {
    random_hash=$(openssl rand -hex 20)

    touch .env.test
    echo "DEBRICKED_USERNAME=$USERNAME" > .env.test
    echo "DEBRICKED_PASSWORD=$PASSWORD" >> .env.test
    echo "DEBRICKED_GIT_URL=https://some.git.host/someuser/repo-is_her3.git" >> .env.test
    echo "COMMIT=test-commit" >> .env.test
    echo "BRANCH=test-branch" >> .env.test
    echo "AUTHOR=test-author" >> .env.test

    run docker run \
        --env-file ./.env.test \
        -v $(pwd):$(pwd) \
        -w /root \
        --entrypoint /argo.sh \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [[ $output =~ " test-commit " && $output =~ "=test-branch " && $output =~ "=test-author " && "$status" -eq 0 ]]
}
