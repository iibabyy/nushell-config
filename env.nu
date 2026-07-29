# ---------------------
# Environment variables
# ---------------------
$env.EDITOR = ($env.EDITOR? | default "code")
$env.VISUAL = ($env.VISUAL? | default "code")

# ---------------------
# PATH env var
# ---------------------
do --env {
    use std/util "path add"

    # Helper to add paths to the PATH env var
    # (checks that the path exists before adding it)
    def add --env [paths] {
        let type = ($paths | describe)

        let paths: list<string> = if $type == "string" {
            [$paths]
        } else if $type == "list<string>" {
            $paths
        }

        for path in $paths {
            if ($path | path exists) {
                path add $path
            }
        }
    }

    # Homebrew (Linux & macOS)
    add [
        "/home/linuxbrew/.linuxbrew/bin",
        "/home/linuxbrew/.linuxbrew/sbin",
        ($env.HOME + "/.linuxbrew/bin"),
        ($env.HOME + "/.linuxbrew/sbin"),
        "/opt/homebrew/bin",
        "/opt/homebrew/sbin",
        ($env.HOME + "/.opencode/bin"),
    ]

    add [
        ($env.HOME + "/.bun/bin"),
        "/usr/local/bin",
        "/usr/local/sbin",
        ($env.HOME + "/.local/bin"),
    ]

    let cargo_home = ($env.CARGO_HOME? | default ($env.HOME + "/.cargo"))
    add ($cargo_home + "/bin")
}

mkdir $nu.cache-dir

let vendor_autoload = ($nu.data-dir | path join "vendor/autoload")
mkdir $vendor_autoload

# Zoxide
# ---------------------
let zoxide_path = ($vendor_autoload | path join "zoxide.nu")
if (which zoxide | is-not-empty) {
    ^zoxide init nushell | save --force $zoxide_path
} else if ($zoxide_path | path exists) {
    rm -f $zoxide_path
}

# Carapace
# ---------------------
let carapace_path = ($vendor_autoload | path join "carapace.nu")
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
if (which carapace | is-not-empty) {
    ^carapace _carapace nushell | save --force $carapace_path
} else if ($carapace_path | path exists) {
    rm -f $carapace_path
}

$env.CARGO_TARGET_DIR = ($env.HOME + "/.cargo/target")

# Starship
# ---------------------
let starship_path = ($vendor_autoload | path join "starship.nu")
if (which starship | is-not-empty) {
    ^starship init nu | save -f $starship_path
} else if ($starship_path | path exists) {
    rm -f $starship_path
}


