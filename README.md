A basic Nushell configuration with custom prompt, utilities and aliases.

[Start with this guide](https://www.nushell.sh/) to understand what Nushell is about.\
You can [check my personal config](https://github.com/iibabyy/nushell-config/tree/my-linux-config) for a real example.

## Quick Start

**First, install Nushell**
```bash
brew install nushell # using brew
cargo install nu --locked # using cargo
npm install -g nushell # using npm
```

> For more installation options, see the [official installation guide](https://www.nushell.sh/book/installation.html).

**Then, install This Configuration**
```bash
nu -c 'git clone https://github.com/iibabyy/nushell-config.git $nu.default-config-dir --recursive'
```
> Or if you already have a config directory, backup and clone:
> ```bash
> nu -c '
>   let config_path = $nu.default-config-dir
>   let backup_path = $"($config_path | path dirname)/nushell.backup"
>
>   # Save the previous nushell directory and clone the new one
>   mv $config_path $backup_path
>   git clone https://github.com/iibabyy/nushell-config.git $config_path --recursive
>
>   # Copy your command history
>   let history_path = $"($backup_path)/history.txt"
>   if ($history_path | path exists) {
>   	cp $history_path $nu.history-path
>   }
> '
> ```

**Recommended:**
- [nu_scripts completions](https://github.com/nushell/nu_scripts/tree/main/custom-completions) - For shell completions. Basic completions (git, cargo, npm, make) are included under `custom/completions/`. Refer to the GitHub repository for more completions.
- [External Completers](https://www.nushell.sh/cookbook/external_completers.html) - For setting up external completers (e.g., carapace, fish, zsh).
- [zoxide](https://github.com/ajeetdsouza/zoxide) - For smart directory jumping

### Default Editor

The default editor is set to `vim`. To change it, open the configuration file:
```bash
config nu
```
Then find the following line and replace `vim` with your preferred editor:
```nu
$env.config.buffer_editor = "vim"  # e.g. "nano", "code", "emacs"
```
