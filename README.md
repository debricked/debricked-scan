# Bitbucket Pipelines Pipe: Debricked Scan

Pipe for integrating Bitbucket with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
script:
  - pipe: debricked/debricked-pipe:0.0.0
    variables:
      USERNAME: "<string>"
      PASSWORD: "<string>"
      # BASE_DIRECTORY: "<string>" # Optional
      # RECURSIVE_FILE_SEARCH: "<boolean>" # Optional
      # EXCLUDED_DIRECTORIES: "<string>" # Optional
      # DEBUG: "<boolean>" # Optional
```
## Variables

| Variable              | Usage                                                       |
| --------------------- | ----------------------------------------------------------- |
| USERNAME (*)          | Your Debricked username |
| PASSWORD (*)          | Your Debricked password |
| BASE_DIRECTORY        | Base directory to scan through. Default: Empty string (repository root). |
| RECURSIVE_FILE_SEARCH | Recursively search through base directory. Default: `true`. |
| EXCLUDED_DIRECTORIES  | A comma separated list of directories to exclude. Default: A list of some common package managers' default modules/vendors directories. |
| DEBUG                 | Turn on extra debug information. Default: `false`. |

_(*) = required variable._

## Prerequisites

## Examples

Basic example:

```yaml
script:
  - pipe: debricked/debricked-pipe:0.0.0
    variables:
      USERNAME: "foo"
      PASSWORD: "bar"
```

Advanced example:

```yaml
script:
  - pipe: debricked/debricked-pipe:0.0.0
    variables:
      USERNAME: "foo"
      PASSWORD: "bar"
      BASE_DIRECTORY: "src/"
      RECURSIVE_FILE_SEARCH: "false"
      EXCLUDED_DIRECTORIES: "target,vendor"
      DEBUG: "true"
```

## Support
If you’d like help with this pipe, or you have an issue or feature request, [let us know on Community](https://community.atlassian.com/t5/forums/postpage/choose-node/true/interaction-style/qanda?add-tags=bitbucket-pipelines,pipes,debricked).

If you’re reporting an issue, please include:

- the version of the pipe
- relevant logs and error messages
- steps to reproduce
