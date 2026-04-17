# Default editor (change this to your preferred editor, e.g. "nano", "code", "emacs")
$env.config.buffer_editor = "agy"

# Deactivate the banner when Nushell start
$env.config.show_banner = false

# Environment variables
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
    ]

    add "/Users/ibaby/.bun/bin"
    add "/opt/homebrew/opt/python@3.14/libexec/bin"

    add "/usr/local/bin"
    add ($env.HOME + "/.local/bin")

    let cargo_home = ($env.CARGO_HOME? | default ($env.HOME + "/.cargo"))
    add ($cargo_home + "/bin")
}

$env.PQ_LIB_DIR = $"(brew --prefix libpq)/lib"

# Zoxide
# ---------------------
const zoxide_path = ($nu.cache-dir + "zoxide.nu")
source $zoxide_path

# Carapace
# ---------------------
const carapace_path = ($nu.cache-dir + "carapace.nu")
source $carapace_path

# Nupm Package Manager (Nushell plugin)
# ---------------------
overlay use nupm/nupm --prefix

use custom *
