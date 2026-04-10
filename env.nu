mkdir $nu.cache-dir

# Zoxide
# ---------------------
const zoxide_path = ($nu.cache-dir + "zoxide.nu")
^zoxide init nushell | save --force $zoxide_path

# Carapace
# ---------------------
const carapace_path = ($nu.cache-dir + "carapace.nu")
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
carapace _carapace nushell | save --force $carapace_path

$env.CARGO_TARGET_DIR = ($env.HOME + "/.cargo/target")
