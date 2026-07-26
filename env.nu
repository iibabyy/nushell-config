# ---------------------
# Environment variables
# ---------------------
$env.EDITOR = ($env.EDITOR? | default ["zed", "-n"])

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

# Zoxide
# ---------------------
const zoxide_path = ($nu.cache-dir + "zoxide.nu")
if (which zoxide | is-not-empty) {
    ^zoxide init nushell | save --force $zoxide_path
} else {
    "" | save --force $zoxide_path
}

# Carapace
# ---------------------
const carapace_path = ($nu.cache-dir + "carapace.nu")
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
if (which carapace | is-not-empty) {
    ^carapace _carapace nushell | save --force $carapace_path
} else {
    "" | save --force $carapace_path
}

$env.CARGO_TARGET_DIR = ($env.HOME + "/.cargo/target")

# Starship
# ---------------------
let starship_vendor = ($nu.data-dir | path join "vendor/autoload")
let starship_path = ($starship_vendor | path join "starship.nu")
if (which starship | is-not-empty) {
    mkdir $starship_vendor
    ^starship init nu | save -f $starship_path
} else if ($starship_path | path exists) {
    rm -f $starship_path
}

