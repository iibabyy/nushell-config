# ---------------------
# Nushell config
# use nu config --doc to see all available config options
# ---------------------

$env.config = ($env.config | merge deep {
	# Deactivate the banner when Nushell start
    show_banner: false,

    # Default editor (change this to your preferred editor, e.g. "nano", "code", "emacs")
    buffer_editor: ["zed", "-n"],

    # use_kitty_protocol (bool): Enable the Kitty keyboard enhancement protocol.
    use_kitty_protocol: true,

    history: {
		# history.file_format (string): The format used for the command history file.
        file_format: "sqlite",

		# history.max_size (int): Maximum number of entries allowed in the history.
        max_size: 300_000,

		# history.isolation (bool): Controls history isolation between shell sessions.
        isolation: true,
    },
})

$env.PQ_LIB_DIR = $"(brew --prefix libpq)/lib"

# ---------------------
# Zoxide
# ---------------------
const zoxide_path = ($nu.cache-dir + "zoxide.nu")
source $zoxide_path

# ---------------------
# Carapace
# ---------------------
const carapace_path = ($nu.cache-dir + "carapace.nu")
source $carapace_path

# ---------------------
# Nupm Package Manager (Nushell plugin)
# ---------------------
overlay use nupm/nupm --prefix

# ---------------------
# Custom exports
# ---------------------
use custom *
