# Tag-replace-workflow

A GitHub Actions pipeline that replaces a line in a text file, commits the change
back to the repository, and publishes a Docker image containing the updated file
to GitHub Container Registry (ghcr.io).

> Created as a solution to a technical assessment for a DevOps Engineer position.
> The task: build a GitHub Action that changes a line in a text file from `tag1`
> to `tag2`, wire it into a reusable workflow, trigger it from a dispatchable
> workflow, commit the change using the default `GITHUB_TOKEN`, and build & push
> a Docker image containing the changed file to ghcr.io.

## How it works

The solution is built from three layers:

1. **Composite action** (`.github/actions/replace-tag`) — replaces every line
   that consists exactly of the search string with the replacement string
   (default: `tag1` → `tag2`) via a Bash script. Inputs: `file`, `search`,
   `replace`. Outputs `changed=true/false` so later steps only commit when the
   file was actually modified.
2. **Reusable workflow** (`.github/workflows/replace-tag-reusable.yaml`) — runs
   the action, then commits and pushes the changed file using the default
   `GITHUB_TOKEN` (no personal access token required).
3. **Dispatchable workflow** (`.github/workflows/release.yaml`) — triggered
   manually from the Actions tab. It first calls the reusable workflow, then a
   second job checks out the freshly pushed commit, builds the `Dockerfile` (which
   copies `content.txt` into the image), and pushes the image to ghcr.io — also
   authenticated with `GITHUB_TOKEN`.

## Usage

1. Go to **Actions → Release → Run workflow**.
2. Optionally override the inputs (`file`, `search`, `replace`) — defaults are
   `content.txt`, `tag1`, `tag2`.
3. The run replaces the line, commits the change as `github-actions[bot]`, and
   publishes the image.

If no line in the file matches the search string exactly, the commit step is
skipped and only the image is rebuilt.

## Result

Pull the published image and print the file it contains:

```sh
docker pull ghcr.io/mduessler/tag-replace-workflow:latest
docker run --rm ghcr.io/mduessler/tag-replace-workflow:latest
```

## Repository layout

```bash
.github/
  actions/replace-tag/     # composite action + replace script
  scripts/commit-and-push  # commit/push helper used by the reusable workflow
  workflows/
    replace-tag-reusable.yaml  # reusable workflow (workflow_call)
    release.yaml               # dispatchable workflow (workflow_dispatch)
Dockerfile                 # copies content.txt into an alpine image
content.txt                # the text file being modified
```
