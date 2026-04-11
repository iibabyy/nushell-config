use gum *
export use aliases.nu *
export use prompt.nu *
export use git_tree gtree
export use docker_prune.nu *
export use bluetooth_toggle.nu [BluetoothConnector toggle_airpods_and_spotify]

export-env {
    use prompt.nu

    # uncomment for background git fetch
    # use hooks.nu
}
