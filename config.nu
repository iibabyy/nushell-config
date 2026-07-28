# # Default editor (change this to your preferred editor, e.g. "nano", "code", "emacs")
# $env.config.buffer_editor = "vim"

# # Deactivate the banner when Nushell start
# $env.config.show_banner = false

# # Zoxide
# # ---------------------
# const zoxide_path = ($nu.cache-dir + "zoxide.nu")
# source $zoxide_path

# # Custom Completions
# # ---------------------

# # Nupm Package Manager (Nushell plugin)
# # ---------------------
# overlay use nupm/nupm --prefix
# # Custom completions are loaded via the `custom` module.
# # Basic completions (git, cargo, npm, make) are cloned under `custom/completions/`
# # and loaded in `custom/mod.nu`.
# #
# # For more completions, check the official nu_scripts repository:
# # https://github.com/nushell/nu_scripts/tree/main/custom-completions
# #
# # Alternatively, you can configure an external completer like carapace.
# # See: https://www.nushell.sh/cookbook/external_completers.html

# # Custom exports
# # ---------------------
# use custom *
