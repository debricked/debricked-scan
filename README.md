# Bitbucket Pipelines Pipe: Debricked Scan

Pipe for integrating Bitbucket with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
script:
  - pipe: debricked/debricked-scan:0.3.0
    variables:
      USERNAME: "<string>"
      PASSWORD: "<string>"
      # BASE_DIRECTORY: "<string>" # Optional
      # RECURSIVE_FILE_SEARCH: "<boolean>" # Optional
      # EXCLUDED_DIRECTORIES: "<string>" # Optional
      # DEBUG: "<boolean>" # Optional
      # SKIP_SCAN: "<boolean>" # Optional
```
## Variables

| Variable              | Usage                                                       |
| --------------------- | ----------------------------------------------------------- |
| USERNAME (*)          | Your Debricked username. Don't have an account? No worries! Get your free 30-day trial at [https://seconds.debricked.com/en/register](https://seconds.debricked.com/en/register?utm_source=bitbucket_pipe) |
| PASSWORD (*)          | Your Debricked password |
| BASE_DIRECTORY        | Base directory to scan through. Default: Empty string (repository root). |
| RECURSIVE_FILE_SEARCH | Recursively search through base directory. Default: `true`. |
| EXCLUDED_DIRECTORIES  | A comma separated list of directories to exclude. Default: A list of some common package managers' default modules/vendors directories. |
| DEBUG                 | Turn on extra debug information. Default: `false`. |
| SKIP_SCAN             | Upload the dependency files automatically when pushing code, without getting the results of the scan in the pipeline.. Default: `false`. |

_(*) = required variable._

## Prerequisites

## Examples

Basic example:

```yaml
script:
  - pipe: debricked/debricked-scan:0.3.0
    variables:
      USERNAME: "foo"
      PASSWORD: "bar"
```

Advanced example:

```yaml
script:
  - pipe: debricked/debricked-scan:0.3.0
    variables:
      USERNAME: "foo"
      PASSWORD: "bar"
      BASE_DIRECTORY: "src/"
      RECURSIVE_FILE_SEARCH: "false"
      EXCLUDED_DIRECTORIES: "target,vendor"
      DEBUG: "true"
      SKIP_SCAN: "true"
```

An example repository using this pipe can be found at https://bitbucket.org/debricked/example-use-of-debricked-pipe/src/master/.

## Support
- If you have an issue or feature request or you'd like help with this pipe, [open an issue](https://bitbucket.org/debricked/debricked-scan/issues/new) or [pull request](https://bitbucket.org/debricked/debricked-scan/pull-requests/new)
- If you have an issue containing sensitive data such as sensitive logs or screenshots, please send an email to [support@debricked.com](mailto:support@debricked.com)

If you're reporting an issue, please include:

- the version of the pipe
- relevant logs and error messages
- steps to reproduce
