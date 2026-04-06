# Default editor (change this to your preferred editor, e.g. "nano", "code", "emacs")
# $env.config.buffer_editor = "vim"

# Deactivate the banner when Nushell start
# $env.config.show_banner = false

# Environment variables
do --env {
  use std/util "path add"

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
  if $nu.os-info.name == "macos" {
    if ("/opt/homebrew/bin" | path exists) { add ["/opt/homebrew/bin", "/opt/homebrew/sbin"] }
    if ("/usr/local/bin" | path exists) { add "/usr/local/bin" }
  }

  add ($env.HOME | path join ".local/bin")

  # Bun
  # add ($env.HOME | path join .bun bin)

  # Cargo
	# let cargo_home = ($env.CARGO_HOME? | default ($env.HOME | path join .cargo))
    # add ($cargo_home | path join "bin")

	# Share target directory across all Cargo projects (saves disk, dependencies, etc...)
	# $env.CARGO_TARGET_DIR = $cargo_home | path join "target"

}

# Zoxide
# ---------------------
# const zoxide_path = ($nu.cache-dir | path join "zoxide.nu")
# source $zoxide_path

# Carapace
# ---------------------
# const carapace_path = ($nu.cache-dir | path join "carapace.nu")
# source $carapace_path

# Nupm Package Manager (Nushell plugin)
# ---------------------
# overlay use nupm/nupm --prefix

use custom *

