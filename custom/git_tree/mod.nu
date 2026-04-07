use completers.nu [git_branches gtree_branches]
use utils.nu cp-gitignored
use worktree-utils.nu *
use span-utils.nu [make-spanned make-spanned-default make-error]
use ../gum "gum confirm"
# Create or remove a git worktree
#
# Creates a new git worktree on a fresh branch, copies gitignored files
# (like .env, build artifacts) from the current directory, and runs
# 'bun install' in parallel. The worktree path is automatically copied
# to the clipboard for easy navigation.
#
# With --rm flag, removes the worktree associated with the branch name.
# Uses gum confirmation prompts (unless --yes is used):
#   1. "Are you sure you want to delete {path}?" (default: yes)
#   2. "Do you want to delete the branch?" (default: no)
# If the branch has a remote tracking branch, both local and remote are deleted.
# Use --yes to skip prompts and automatically delete both worktree and branch.
#
# Default worktree location: <current-dir>/.worktrees/<branch-name>
# Branch names with slashes (e.g., feature/foo) are converted to hyphens.
@example "Create worktree for a feature branch" {gtree feature/new-auth}
@example "Create worktree at custom path" {gtree bugfix/login-error --path ~/temp/bugfix}
@example "Create worktree from specific base branch" {gtree hotfix/security --base-branch main}
@example "Remove a worktree by branch name (with confirmation prompts)" {gtree feature/new-auth --rm}
@example "Remove worktree and branch without prompts" {gtree feature/new-auth --rm --yes}
export def gtree [
  branch: string@gtree_branches  # Name of the branch (to create or remove with --rm)
  --rm                         # Remove mode: remove existing worktree for this branch
  --path(-p): path             # Custom path for the worktree (defaults to <workdir>/.worktrees/<branch>)
  --base-branch: string@git_branches  # Base branch to branch from (defaults to current branch)
  --workdir(-w): path          # Base directory for the worktree (defaults to $env.PWD)
  --force(-f)                  # [--rm only] Force removal of dirty worktrees and force-delete branch
  --yes(-y)                    # [--rm only] Skip confirmation prompts (deletes worktree and branch)
]: nothing -> string {
    # Wrap all user-provided parameters at entry
    let spanned_branch = (make-spanned $branch (metadata $branch))
    let spanned_path = if $path != null { make-spanned $path (metadata $path) } else { null }
    let spanned_base = if $base_branch != null { make-spanned $base_branch (metadata $base_branch) } else { null }
    let spanned_workdir = (make-spanned-default $workdir $env.PWD (metadata $workdir))
    # Handle remove mode
    if $rm {
        validate-remove-mode-flags $spanned_path $spanned_base
        # Validate git repo first
        validate-git-repo $spanned_workdir
        # Unwrap for pure computation (can't fail)
        let workdir = ($spanned_workdir.value | path expand)
        # Find worktree by branch name from git worktree list
        let resolved_path = (get-worktree-path-by-branch $spanned_branch.value $workdir)
        if $resolved_path == null {
            make-error $"No worktree found for branch '($spanned_branch.value)'" $spanned_branch --label "worktree not found" --hint "Use 'git worktree list' to see all worktrees"
        }
        # Call gtree-remove with spanned values
        match [$force, $yes] {
            [true, true] => { gtree-remove $resolved_path $spanned_branch $spanned_workdir --force --yes }
            [true, false] => { gtree-remove $resolved_path $spanned_branch $spanned_workdir --force }
            [false, true] => { gtree-remove $resolved_path $spanned_branch $spanned_workdir --yes }
            [false, false] => { gtree-remove $resolved_path $spanned_branch $spanned_workdir }
        }
    } else {
        # Create mode
        validate-create-mode-flags $force $yes
        gtree-create $spanned_branch $spanned_workdir $spanned_path $spanned_base
    }
}
