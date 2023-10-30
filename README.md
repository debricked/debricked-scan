# Bitbucket Pipelines Pipe: Debricked Scan

Pipe for integrating Bitbucket with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities and compliance risks.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
script:
  - pipe: debricked/debricked-scan:2.3.4
    variables:
      DEBRICKED_TOKEN: $DEBRICKED_TOKEN
      # BASE_DIRECTORY: "<string>" # Optional
      # DEBRICKED_EXCLUSIONS: "<string>" # Optional
```

You should mask your debricked token in order to avoid revealing your token in the pipeline, please refer to [our Bitbucket documentation](https://debricked.com/documentation/1.0/integrations/ci-build-systems/bitbucket).

## Variables

| Variable                      | Usage                                                                                                                                                                                         |
|-------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DEBRICKED_TOKEN (*)           | Your Debricked access token. See ["How do I generate an access token?" Documentation](https://portal.debricked.com/administration-47/how-do-i-generate-an-access-token-130) for instructions. |
| BASE_DIRECTORY                | Base directory to scan, relative to repository root. Default: Empty string (repository root).                                                                                                 |
| DEBRICKED_EXCLUSIONS          | Please refer to [our documentation (search in page for --exclusions) for syntax](https://portal.debricked.com/debricked-cli-63/debricked-cli-documentation-298#scan)                          |

_(*) = required

An example repository using this pipe can be found at https://bitbucket.org/debricked/example-use-of-debricked-pipe/src/master/.

## Support
- If you have an issue or feature request or you'd like help with this pipe, [open an issue](https://bitbucket.org/debricked/debricked-scan/issues/new) or [pull request](https://bitbucket.org/debricked/debricked-scan/pull-requests/new)
- If you have an issue containing sensitive data such as sensitive logs or screenshots, please send an email to [support@debricked.com](mailto:support@debricked.com)

If you're reporting an issue, please include:

- the version of the pipe
- relevant logs and error messages
- steps to reproduce
