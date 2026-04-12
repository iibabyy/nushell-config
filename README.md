# Nushell Configuration

Personal Nushell configuration with custom prompt, utilities and aliases.

## Quick Start

### Install Nushell

First, install [Nushell](https://www.nushell.sh/)

**Using Homebrew:**
```bash
brew install nushell
```

**Using cargo:**
```bash
cargo install nu --locked
```

For more installation options, see the [official installation guide](https://www.nushell.sh/book/installation.html).

### Install This Configuration

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

### Run Nushell
```bash
nu
```

## Requirements

- [Nushell](https://www.nushell.sh/)

**Recommended:**
- [carapace](https://github.com/carapace-sh/carapace) - For shell completions
- [zoxide](https://github.com/ajeetdsouza/zoxide) - For smart directory jumping

## Structure

```
╭── config.nu           # Main configuration file
├── env.nu              # Environment setup
├── custom/             # Custom modules
│   └── ...
└── completions/        # External completions
```

## Customization

### Default Editor

The default editor is set to `vim`. To change it:

1. Open the configuration file:
```bash
config nu
```

2. Find the following line and replace `vim` with your preferred editor:
```nu
$env.config.buffer_editor = "vim"  # e.g. "nano", "code", "emacs"
```

For more configuration options, see the [Nushell Configuration Guide](https://www.nushell.sh/book/configuration.html).

### General

Edit `config.nu` to modify imports and settings.

Add your own modules in `custom/` and export them in `custom/mod.nu`.
