# Bitbucket Pipelines Pipe: Debricked Scan

Pipe for integrating Bitbucket with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
script:
  - pipe: debricked/debricked:0.0.0
    variables:
      NAME: "<string>"
      # DEBUG: "<boolean>" # Optional
```
## Variables

| Variable              | Usage                                                       |
| --------------------- | ----------------------------------------------------------- |
| NAME (*)              | The name that will be printed in the logs |
| DEBUG                 | Turn on extra debug information. Default: `false`. |

_(*) = required variable._

## Prerequisites

## Examples

Basic example:

```yaml
script:
  - pipe: debricked/debricked:0.0.0
    variables:
      NAME: "foobar"
```

Advanced example:

```yaml
script:
  - pipe: debricked/debricked:0.0.0
    variables:
      NAME: "foobar"
      DEBUG: "true"
```

## Support
If you’d like help with this pipe, or you have an issue or feature request, [let us know on Community](https://community.atlassian.com/t5/forums/postpage/choose-node/true/interaction-style/qanda?add-tags=bitbucket-pipelines,pipes,debricked).

If you’re reporting an issue, please include:

- the version of the pipe
- relevant logs and error messages
- steps to reproduce
