# Project instructions

## Git account isolation

- All commits and pushes in this repository must use `xee-martin`. Never use `xee2211`.
- Repository-local author and committer: `xee-martin <344557589+xee-martin@users.noreply.github.com>`.
- Only push to `https://github.com/xee-martin/paygo-home.git`.
- Keep `core.hooksPath=.githooks` enabled. Do not bypass the identity hooks.
- Authentication uses the repository-local `.git/gh-xee-martin` GitHub CLI configuration. Do not switch the global/default GitHub account or modify global Git identity.
- After cloning, configure repository-local identity and authentication before committing; enable hooks with `git config --local core.hooksPath .githooks`.

## ServBay MCP

Use ServBay MCP for local development environment tasks, including websites, domains, TLS, web servers, runtimes, databases, service status, logs, ports, packages, and backups. Inspect relevant ServBay state before editing project code to compensate for a suspected environment issue. For write/destructive ServBay actions, explain the intended effect and use the MCP confirmation_token flow. Do not ask for secrets or private keys in chat.
