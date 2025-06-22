# Git CLI Cheatsheet

This cheatsheet provides a concise reference for commonly used Git Command Line Interface (CLI) commands. It is designed for quick lookup, covering essential operations for repository management, branching, committing, collaboration, and troubleshooting. Commands are organized by category with brief explanations and examples, suitable for both novice and experienced users.

## Repository Setup

- **Initialize a new Git repository**:
  ```bash
  git init
  ```
  Creates a `.git` directory in the current folder, starting version control.

- **Clone an existing repository**:
  ```bash
  git clone <repository_url>
  ```
  Downloads a repository (e.g., from GitHub) to the local machine. Example:
  ```bash
  git clone https://github.com/user/repo.git
  ```

- **Check repository status**:
  ```bash
  git status
  ```
  Displays the current branch, staged changes, and untracked files.

## Configuration

- **Set user information** (global):
  ```bash
  git config --global user.name "<Your Name>"
  git config --global user.email "<your.email@example.com>"
  ```
  Configures the author name and email for commits.

- **View configuration**:
  ```bash
  git config --list
  ```
  Lists all Git configuration settings.

## Staging and Committing

- **Add files to staging**:
  ```bash
  git add <file>
  git add .
  ```
  Stages specific files or all changes in the current directory for commit.

- **Commit changes**:
  ```bash
  git commit -m "<commit message>"
  ```
  Saves staged changes with a descriptive message. Example:
  ```bash
  git commit -m "Add README file"
  ```

- **Amend the last commit**:
  ```bash
  git commit --amend
  ```
  Modifies the most recent commit (e.g., to update the message or add files).

## Branching

- **List branches**:
  ```bash
  git branch
  ```
  Shows all local branches; the current branch is marked with `*`.

- **Create a new branch**:
  ```bash
  git branch <branch_name>
  ```
  Creates a branch but does not switch to it.

- **Switch to a branch**:
  ```bash
  git checkout <branch_name>
  ```
  Moves to the specified branch.

- **Create and switch to a new branch**:
  ```bash
  git checkout -b <branch_name>
  ```
  Combines branch creation and checkout. Example:
  ```bash
  git checkout -b feature/login
  ```

- **Delete a branch**:
  ```bash
  git branch -d <branch_name>
  ```
  Removes a merged branch. Use `-D` to force deletion of unmerged branches.

## Merging and Rebasing

- **Merge a branch**:
  ```bash
  git merge <branch_name>
  ```
  Integrates changes from `<branch_name>` into the current branch. Example:
  ```bash
  git checkout main
  git merge feature/login
  ```

- **Rebase a branch**:
  ```bash
  git rebase <branch_name>
  ```
  Reapplies commits from the current branch onto `<branch_name>`. Example:
  ```bash
  git checkout feature/login
  git rebase main
  ```

- **Resolve merge conflicts**:
  - Edit conflicting files to resolve differences.
  - Mark as resolved:
    ```bash
    git add <file>
    ```
  - Complete the merge:
    ```bash
    git commit
    ```

## Remote Repositories

- **Add a remote repository**:
  ```bash
  git remote add <name> <repository_url>
  ```
  Links a local repository to a remote one. Example:
  ```bash
  git remote add origin https://github.com/user/repo.git
  ```

- **List remote repositories**:
  ```bash
  git remote -v
  ```
  Shows remote names and URLs.

- **Push changes to remote**:
  ```bash
  git push <remote_name> <branch_name>
  ```
  Uploads local commits to the remote repository. Example:
  ```bash
  git push origin main
  ```

- **Fetch remote changes**:
  ```bash
  git fetch <remote_name>
  ```
  Downloads remote changes without merging them.

- **Pull remote changes**:
  ```bash
  git pull <remote_name> <branch_name>
  ```
  Fetches and merges remote changes. Example:
  ```bash
  git pull origin main
  ```

## History and Inspection

- **View commit history**:
  ```bash
  git log
  ```
  Displays a detailed commit history. Use `--oneline` for a compact view:
  ```bash
  git log --oneline
  ```

- **Show changes in a commit**:
  ```bash
  git show <commit_hash>
  ```
  Displays details and changes for a specific commit.

- **Compare changes**:
  ```bash
  git diff
  ```
  Shows unstaged changes. Use `git diff --staged` for staged changes.

## Undoing Changes

- **Discard unstaged changes**:
  ```bash
  git restore <file>
  ```
  Reverts file modifications. Use `git restore .` for all unstaged files.

- **Unstage files**:
  ```bash
  git restore --staged <file>
  ```
  Removes files from the staging area.

- **Reset to a previous commit**:
  ```bash
  git reset <commit_hash>
  ```
  Moves the branch pointer to `<commit_hash>`. Use `--hard` to discard changes:
  ```bash
  git reset --hard <commit_hash>
  ```

- **Revert a commit**:
  ```bash
  git revert <commit_hash>
  ```
  Creates a new commit that undoes the specified commit.

## Stashing

- **Save changes temporarily**:
  ```bash
  git stash
  ```
  Stores uncommitted changes and reverts to a clean working directory.

- **List stashed changes**:
  ```bash
  git stash list
  ```

- **Apply a stash**:
  ```bash
  git stash apply
  ```
  Reapplies the most recent stash. Use `git stash apply stash@{n}` for a specific stash.

- **Remove a stash**:
  ```bash
  git stash drop
  ```
  Deletes the most recent stash. Use `git stash clear` to remove all stashes.

## Tagging

- **Create a tag**:
  ```bash
  git tag <tag_name>
  ```
  Marks a commit (e.g., for releases). Example:
  ```bash
  git tag v1.0.0
  ```

- **List tags**:
  ```bash
  git tag
  ```

- **Push tags to remote**:
  ```bash
  git push <remote_name> <tag_name>
  ```
  Example:
  ```bash
  git push origin v1.0.0
  ```

- **Delete a tag**:
  ```bash
  git tag -d <tag_name>
  ```

## Troubleshooting

- **Fix a detached HEAD**:
  ```bash
  git checkout <branch_name>
  ```
  Or create a new branch to save changes:
  ```bash
  git checkout -b new-branch
  ```

- **Recover a deleted branch**:
  ```bash
  git branch <branch_name> <commit_hash>
  ```
  Find the commit hash using `git reflog`.

- **View recent operations**:
  ```bash
  git reflog
  ```
  Shows a log of HEAD movements for recovering lost commits.

## Best Practices

- Commit frequently with clear messages.
- Use branches for features or bug fixes.
- Pull before pushing to avoid conflicts.
- Regularly push tags for release milestones.
- Verify commands with `git status` and `git log`.

This cheatsheet covers core Git CLI commands for efficient version control. For advanced usage, consult the official Git documentation (`git help <command>`).