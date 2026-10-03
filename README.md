# t3code-container

A ready-to-use development container for [T3 Code](https://github.com/pingdotgg/t3code) and [Claude Code](https://claude.com/claude-code).

Run it on a server, pair your browser, and let agents work in your projects.
Your home folder and workspace live on the host, so nothing is lost when the container is recreated.

## Features

- **Always up to date**: Claude Code and T3 Code update on every start, or on demand with `update`.
- **No permission hassle**: everything that updates lives in your home folder, owned by your user.
- **SSH access** using the public keys of your GitHub account.
- **Browser automation** for agents through the [Playwright MCP](https://github.com/microsoft/playwright-mcp), with headless Chromium and Firefox.
- **Self-repairing startup**: every start fills in whatever is missing, without touching what is already there.
- **Common dev tools** on Ubuntu 24.04, with passwordless `sudo` for anything else.

## What's included

| Tool | Installed | Updated |
|---|---|---|
| Claude Code, T3 Code | In your home folder | On every start, or with `update` |
| Playwright browsers (Chromium, Firefox) | In your home folder | On every start, or with `update` |
| Node.js (LTS), Go, Rust, uv, GitHub CLI | In the image | Weekly image rebuild |
| git, ripgrep, jq, build-essential, Python 3, … | In the image | Weekly image rebuild |

## Quick start

1. Copy [`compose.yaml`](compose.yaml) to your server.
2. Create a `.env` file next to it:
   ```
   GITHUB_USERNAME=your-github-username
   ```
3. Set `PUID` / `PGID` in `compose.yaml` to the user and group that own your `home` and `workspace` folders on the host (`id` shows yours).
4. Start it:
   ```
   docker compose up -d
   ```
   > **Note:** the container must start as root. Don't set a user. See [How it works](#how-it-works).
5. Open the pairing URL from the logs (`docker compose logs`).

## Configuration

| Variable | Default | Description |
|---|---|---|
| `GITHUB_USERNAME` | (required) | Your GitHub username. Sets your user name (lowercase), your SSH keys and your default git identity. |
| `PUID` | `1000` | User ID of your user inside the container. |
| `PGID` | `1000` | Group ID of your user inside the container. |

| Mount | Description |
|---|---|
| `/home` | Holds your home folder, `/home/<username>`. Claude Code, T3 Code and all settings live here. |
| `/workspace` | Your projects. |

| Port | Description |
|---|---|
| `3773` | T3 Code web interface. |
| `22` | SSH. Map it to something like `2222` on the host. |

Give the container a larger `/dev/shm` (`shm_size: 1gb`), or headless Chromium may crash on bigger pages.

## First start

The first start takes a few minutes while Claude Code, T3 Code and the Playwright browsers download.
After that, starts are quick.

1. **Pair your browser.** The logs show a pairing URL, valid for 5 minutes. It contains the container's internal IP; replace it with your server's IP.
2. **Log in to Claude.** SSH in and run `claude`.
3. **Log in to GitHub** (optional): `gh auth login`, then `gh auth setup-git`.
4. **Enable T3 Connect** (optional): `t3 connect link`, then restart the container.

All logins are stored in your home folder, so you do this once.

## Usage

### SSH

```
ssh -p 2222 <username>@<server>
```

Your keys are fetched from `https://github.com/<username>.keys` on every start.
Add or remove a key on GitHub and restart the container to apply it.
Keys in your own `~/.ssh/authorized_keys` also work.

### Pairing another device

The pairing URL in the logs expires after 5 minutes. To get a new one, SSH in and run:

```
t3 pair
```

### Updating

```
update
```

This updates Claude Code, T3 Code and the Playwright browsers, then restarts T3 Code.
If you run it from a terminal inside T3 Code, that terminal closes during the restart.

Everything else comes with the image, which is rebuilt weekly. Pull the new image to update.

### Browser automation

T3 Code's own browser tools need the T3 Code desktop app, so they don't work in this container.
Instead, agents get the Playwright MCP, which runs headless Chromium inside the container.
This works from any client, including mobile, and can reach dev servers on `localhost`.

## How it works

On every start, the container:

1. Creates your user with `PUID` / `PGID`.
2. Restores the SSH host keys from your home folder, or creates and saves them on the first start.
3. Fetches your SSH keys from GitHub and starts the SSH server.
4. Switches from root to your user.
5. Copies default dotfiles into your home folder, skipping any that already exist.
6. Sets your git name and email from your GitHub profile, if they aren't set yet.
7. Installs or updates Claude Code, T3 Code and the Playwright browsers.
8. Registers the Playwright MCP with Claude Code, if it isn't registered yet.
9. Starts T3 Code, restarting it whenever it stops.

## License

[MIT](LICENSE)
