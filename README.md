# Dotfiles (Fedora + Hyprland)

My Fedora setup: one script installs the repos, packages and codecs, and
[GNU Stow](https://www.gnu.org/software/stow/) symlinks the configs into `$HOME`.

## Quick start

Requires **Fedora 44 or newer** (the Hyprland COPR doesn't build for older releases).
On a minimal install the script adds SDDM as the login screen; on Workstation it keeps GDM.

On a fresh Fedora install:

```sh
sudo dnf install -y git stow
git clone https://github.com/Cheshirecat12/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh                 # Intel GPU (default)
# ./install.sh --gpu amd     # AMD GPU
# ./install.sh --nvidia      # also install the Nvidia driver
```

Then log out and back in. Enable the OpenH264 plugin in Firefox's settings.

> Clone the repo somewhere permanent (e.g. `~/.dotfiles`), not `/tmp`, because
> the configs are symlinks that point into it.

## Running single steps

```sh
./install.sh --help
./install.sh repos packages   # run only these steps
./install.sh stow             # (re)link every config package
./scripts/stow.sh nvim kitty  # link only some packages
stow -D -t ~ nvim             # unlink a package
```

| Step       | Script                | What it does |
| :--------- | :-------------------- | :----------- |
| `repos`    | `scripts/repos.sh`    | dnf tuning, RPM Fusion, Terra, Flathub, `kylegospo/preload` COPR |
| `packages` | `scripts/packages.sh` | base CLI tools, kitty, neovim, firefox |
| `hyprland` | `scripts/hyprland.sh` | Hyprland, portals, polkit agent, hyprpaper/idle/lock/shot from the [lionheartp/Hyprland](https://copr.fedorainfracloud.org/coprs/lionheartp/Hyprland) COPR, plus waybar, wofi, swaync, applets; SDDM if no login manager |
| `codecs`   | `scripts/codecs.sh`   | multimedia codecs, full ffmpeg, VA-API (Intel/AMD), optional Nvidia, OpenH264 |
| `zsh`      | `scripts/zsh.sh`      | oh-my-zsh (unattended), powerlevel10k, plugins, `chsh` to zsh |
| `icons`    | `scripts/icons.sh`    | Flat-Remix-Blue-Dark icon theme |
| `stow`     | `scripts/stow.sh`     | symlinks every package into `$HOME` |

## Hyprland

Hyprland comes from the [lionheartp/Hyprland](https://copr.fedorainfracloud.org/coprs/lionheartp/Hyprland)
COPR, the one the [official wiki](https://wiki.hypr.land/getting-started/installation/) recommends
for Fedora. The `hyprland` step disables older Hyprland COPRs (`solopasha/hyprland`,
`sdegler/hyprland`) so packages don't get mixed, then upgrades to the COPR's versions.

The config is `~/.config/hypr/hyprland.lua` (Lua config, Hyprland 0.55+). The old
`hyprland.conf` format is deprecated upstream. `hypridle` uses the Lua dispatch syntax
(`hyprctl dispatch 'hl.dsp.dpms({action = "off"})'`) and `hyprpaper` uses the 0.8+ `wallpaper { }` blocks.
`stow.sh` skips the `hyprland`, `hypridle` and `hyprpaper` packages while an older Hyprland
(< 0.55) is installed; set `FORCE_HYPR=1` to link them anyway.

After logging in: `hyprctl configerrors` shows any config problems.

## Notes

Each step can be run again safely. If a real file is in the way of a symlink,
`stow.sh` moves it to `~/.dotfiles_backup/<date>/` first.

## Stow packages

| Package      | Target |
| :----------- | :----- |
| `zsh`        | `~/.zshrc`, `~/.p10k.zsh` |
| `kitty`      | `~/.config/kitty/` (keymaps in [docs/kitty.md](docs/kitty.md)) |
| `nvim`       | `~/.config/nvim/` (lazy.nvim, bootstraps itself on first launch) |
| `eza`        | `~/.config/eza/theme.yml` (catppuccin) |
| `fonts`      | `~/.local/share/fonts/` (JetBrainsMono and CaskaydiaMono Nerd Fonts) |
| `wallpapers` | `~/.local/share/wallpapers/` |
| `hyprland`   | `~/.config/hypr/hyprland.lua` |
| `hypridle`   | `~/.config/hypr/hypridle.conf` |
| `hyprlock`   | `~/.config/hypr/hyprlock.conf` |
| `hyprpaper`  | `~/.config/hypr/hyprpaper.conf` |
| `waybar`     | `~/.config/waybar/` |
| `wofi`       | `~/.config/wofi/` |
| `swaync`     | `~/.config/swaync/` |

Packages are stowed with `--no-folding`, so several packages can share
`~/.config/hypr/`.

## TODO

- [ ] Battery on waybar: red and a notification when the battery is under 20%
