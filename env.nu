# ---------------------
# Environment variables
# ---------------------

if ($env.ZED_TERM? == "true") {
	$env.EDITOR = "zed"
} else {
	$env.EDITOR = "nvim"
}

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

    # Homebrew (macOS)
    add [
        "/opt/homebrew/bin",
        "/opt/homebrew/sbin",
        "/opt/homebrew/opt/python@3.14/libexec/bin",
        "/opt/homebrew/Cellar/supabase-beta/2.100.2-beta.1/bin/",
    ]

    add [
        "/Users/ibaby/.bun/bin",
        "/usr/local/bin",
        ($env.HOME + "/.local/bin"),
    ]

    let cargo_home = ($env.CARGO_HOME? | default ($env.HOME + "/.cargo"))
    add ($cargo_home + "/bin")
}

mkdir $nu.cache-dir

# Zoxide
# ---------------------
const zoxide_path = ($nu.cache-dir + "zoxide.nu")
^/opt/homebrew/bin/zoxide init nushell | save --force $zoxide_path
# Carapace
# ---------------------
const carapace_path = ($nu.cache-dir + "carapace.nu")
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
/opt/homebrew/bin/carapace _carapace nushell | save --force $carapace_path

$env.CARGO_TARGET_DIR = ($env.HOME + "/.cargo/target")
# Starship
# ---------------------
mkdir ($nu.data-dir | path join "vendor/autoload")
/opt/homebrew/bin/starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
