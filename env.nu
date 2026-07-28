# Environment variables
do --env {
	use std/util "path add"

	# Helper to add paths to the PATH env var
	def add --env [paths] {
	    let type = ($paths | describe)

	    let paths: list<string> = if $type == "string" {
			[$paths]
		} else if $type == "list<string>" {
			$paths
		} else {
			return
		}

	    for path in $paths {
			# (checks that the path exists before adding it)
	        if ($path | path exists) { path add $path }
	    }
	}

	# Homebrew (macOS)
	add [
	    "/opt/homebrew/bin",
	    "/opt/homebrew/sbin",
	]

	add [
		"/usr/local/bin",
		($env.HOME + "/.local/bin"),
	]

	let cargo_home = ($env.CARGO_HOME? | default ($env.HOME + "/.cargo"))
	add ($cargo_home + "/bin")
}

# mkdir $nu.cache-dir

# # Zoxide
# # ---------------------
# const zoxide_path = ($nu.cache-dir + "zoxide.nu")
# ^zoxide init nushell | save --force $zoxide_path

