# ---------------------
# Nushell config
# use nu config --doc to see all available config options
# ---------------------

$env.config = ($env.config | merge deep {
	# Deactivate the banner when Nushell start
    show_banner: false,

    # Default editor (change this to your preferred editor, e.g. "nano", "code", "emacs")
    buffer_editor: "nvim",

    # use_kitty_protocol (bool): Enable the Kitty keyboard enhancement protocol.
    use_kitty_protocol: true,

    history: {
		# history.file_format (string): The format used for the command history file.
        file_format: sqlite,

		# history.max_size (int): Maximum number of entries allowed in the history.
        max_size: 3_000,

		# history.isolation (bool): Controls history isolation between shell sessions.
        isolation: true,
    },
})

$env.config.keybindings ++= [
    {
        name: completion_menu
        modifier: control_shift
        keycode: char_-
        mode: emacs
        event: { edit: undo }
    }
    {
        name: delete_word_backward
        modifier: control
        keycode: backspace
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: BackspaceWord }
    }
]


$env.PQ_LIB_DIR = if (which brew | is-not-empty) {
    let libpq_prefix = (do { ^brew --prefix libpq } | complete)
    if $libpq_prefix.exit_code == 0 {
        ($libpq_prefix.stdout | str trim | path join "lib")
    } else {
        null
    }
} else if ("/usr/lib64/libpq.so" | path exists) {
    "/usr/lib64"
} else if ("/usr/lib/libpq.so" | path exists) {
    "/usr/lib"
} else {
    null
}

# ---------------------
# Nupm Package Manager (Nushell plugin)
# ---------------------
overlay use nupm/nupm --prefix

# ---------------------
# Custom exports
# ---------------------
use custom *


# Starship
# ---------------------
const vendor_autoload = ($nu.data-dir | path join "vendor/autoload")
const starship_path = ($vendor_autoload | path join "starship.nu")
source $starship_path

# ---------------------
# nu_scripts completions
# ---------------------
use nu_scripts/custom-completions/cargo/cargo-completions.nu *
use nu_scripts/custom-completions/claude/claude-completions.nu *
use nu_scripts/custom-completions/curl/curl-completions.nu *
use nu_scripts/custom-completions/docker/docker-completions.nu *
use nu_scripts/custom-completions/gh/gh-completions.nu *
use nu_scripts/custom-completions/git/git-completions.nu *
use nu_scripts/custom-completions/make/make-completions.nu *
use nu_scripts/custom-completions/npm/npm-completions.nu *
use nu_scripts/custom-completions/rustup/rustup-completions.nu *
use nu_scripts/custom-completions/zoxide/zoxide-completions.nu *
source "~/.cargo/env.nu"
