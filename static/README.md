# Static site root

This folder is the top-level static site entrypoint.

- Sub-sites live in subfolders under this directory.
- Keep shared assets (CSS, images, etc.) in /assets so all sub-sites can reference them.
- Each sub-site should include its own index.html and any local assets.
- Routing: sub-sites should use root-absolute links (e.g. /therobvault/) to avoid path issues.

If you add a new sub-site, create a new folder and place the site files there.
