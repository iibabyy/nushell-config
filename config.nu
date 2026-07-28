# ---------------------
# Nushell config
# use nu config --doc to see all available config options
# ---------------------

$env.config = ($env.config | merge deep {
	# Deactivate the banner when Nushell start
    show_banner: false,

    # Default editor (change this to your preferred editor, e.g. "nano", "code", "emacs")
    buffer_editor: ($env.EDITOR? | $env.VISUAL? | default "zed"),

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
