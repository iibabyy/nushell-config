export use aliases.nu *
export use prompt.nu *
export use git_tree gtree
export use docker_prune.nu *
export use bluetooth_toggle.nu *

export-env {
    # uncomment for a custom prompt
    # for better prompts, I recommend starship (https://starship.rs/)
    # use prompt.nu

    # uncomment for background git fetch
    # use hooks.nu
}
