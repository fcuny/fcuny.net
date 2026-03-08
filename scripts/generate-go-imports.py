#!/usr/bin/env python3
"""Generate HTML pages for Go vanity import paths.

This script reads a configuration file listing Go modules and generates
HTML pages with the necessary meta tags for Go's module system to resolve
imports like `fcuny.net/ssh-cert-info` to the actual GitHub repository.
"""

import json
import os
import sys
from pathlib import Path

TEMPLATE = """<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="go-import" content="{domain}/{module} git https://github.com/{github_user}/{module}">
    <meta name="go-source" content="{domain}/{module} https://github.com/{github_user}/{module} https://github.com/{github_user}/{module}/tree/main{{/dir}} https://github.com/{github_user}/{module}/blob/main{{/dir}}/{{file}}#L{{line}}">
    <meta http-equiv="refresh" content="0; url=https://pkg.go.dev/{domain}/{module}">
    <title>{domain}/{module}</title>
    <link rel="stylesheet" href="/static/style.css" />
  </head>
  <body>
    <main>
      <article>
        <p>Redirecting to <a href="https://pkg.go.dev/{domain}/{module}">pkg.go.dev/{domain}/{module}</a>...</p>
        <p>Source: <a href="https://github.com/{github_user}/{module}">github.com/{github_user}/{module}</a></p>
      </article>
    </main>
  </body>
</html>
"""


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <config.json> <output-dir>", file=sys.stderr)
        sys.exit(1)

    config_path = Path(sys.argv[1])
    output_dir = Path(sys.argv[2])

    with open(config_path) as f:
        config = json.load(f)

    domain = config["domain"]
    github_user = config["github_user"]
    modules = config["modules"]

    for module in modules:
        module_dir = output_dir / module
        module_dir.mkdir(parents=True, exist_ok=True)

        html = TEMPLATE.format(
            domain=domain,
            github_user=github_user,
            module=module,
        )

        index_path = module_dir / "index.html"
        index_path.write_text(html)
        print(f"Generated: {index_path}")


if __name__ == "__main__":
    main()
