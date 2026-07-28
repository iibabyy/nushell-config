export use aliases.nu *
export use prompt.nu *
export use git_tree gtree
export use docker_prune.nu *
export use bluetooth_toggle.nu *

# Custom completions
# ---------------------
# Basic completions cloned from https://github.com/nushell/nu_scripts/tree/main/custom-completions
export use completions/git-completions.nu *
export use completions/cargo-completions.nu *
export use completions/npm-completions.nu *
export use completions/make-completions.nu *

export-env {
    # uncomment for a custom prompt
    # for better prompts, I recommend starship (https://starship.rs/)
    # use prompt.nu

    # uncomment for background git fetch
    # use hooks.nu
}
