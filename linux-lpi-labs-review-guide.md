# Linux LPI Lab Review Guide & Memory

> **Antigravity Context:** This document captures the complete operational memory, audit criteria, command workflows, and reviewer guidelines for reviewing LPI Linux labs (Lab 04: Users, Groups & Accounts; Lab 05: Processes, Jobs & Priorities). Reference this file in Antigravity sessions on macOS or Linux to maintain consistency during PR reviews.

---

## 1. Overview & Review Philosophy

When reviewing PR submissions in Linux learning repositories (such as `bonfacekiplangat/cloud-linux-learnings` and `harisonchirchir/CodeCradle`), evaluate both **practical execution** (terminal outputs, screenshots, audit integrity) and **conceptual clarity** ("Explain It" sections).

### General Review Rules:
- **Terminal Evidence:** Every task must feature pasted command outputs or clear terminal captures showing hostnames (`hostname`) and timestamps (`date`).
- **One-Line Reasons:** Runbooks (such as Boss Challenges) must explain *why* each command was run in sequence, not merely dump bare shell commands.
- **Root vs User Permissions:** Ensure commands requiring root privileges (`chage`, modifying `/etc/shadow`, `useradd`, lowering niceness) use `sudo` or root sessions, and verify permission-denied cases.
- **No Unresolved Placeholders:** Verify that template placeholders (e.g. `[PID]`, `[real value]`) are replaced with real execution values.

---

## 2. Lab 04: Users, Groups & Accounts (LPI 107.1, 110.1)

### Key Databases & Architecture
* **/etc/passwd (World-readable):**
  - Format: `username:x:UID:GID:GECOS:home:shell` (7 fields).
  - `x` in field 2 is a placeholder indicating that password hashes reside in `/etc/shadow`.
  - Must remain world-readable (0644) so local utilities and libraries can resolve UIDs to usernames without requiring root privileges.
* **/etc/shadow (Restricted 0640/0600):**
  - Contains password hashes and aging parameters: `username:hash:lastchange:min:max:warn:inactive:expire:reserved`.
  - Prefix identification:
    - `$6$` = SHA-512 (standard default on older/established Linux systems).
    - `$y$` = yescrypt (modern default on current Debian/Ubuntu distributions).
  - Status flags:
    - `!` = Locked password (or account created without password). Prepending `!` invalidates the hash while keeping the salt/hash intact.
    - `*` = Disabled login / system account not intended to have a password.
* **/etc/group & NSS (`getent`):**
  - Primary group is defined by GID in `/etc/passwd` (field 4); default for new files.
  - Supplementary groups are defined in `/etc/group` for access permissions.
  - `getent passwd <user>` and `getent group <group>` query via Name Service Switch (`/etc/nsswitch.conf`), which resolves centralized identity stores (LDAP, SSSD, Active Directory) that `grep /etc/passwd` will miss.

### Service Accounts & Login Restrictions
* **Login Shells:**
  - Service accounts use `/usr/sbin/nologin` or `/bin/false`.
  - **What still works:** Background daemons, system services, cron jobs, file/socket ownership, and execution via `sudo -u <service> <command>`.
  - **What is blocked:** Interactive login sessions (SSH, console, `su -`, GUI login).

### Account Lifecycle & Offboarding
| Operation | Command | Purpose & Appropriate Scenario |
|---|---|---|
| **Lock** | `usermod -L <user>` | Immediate, reversible suspension. Use during emergency investigations or initial offboarding triage. |
| **Expire** | `chage -E YYYY-MM-DD <user>` | Scheduled, automatic expiration. Use for temporary staff, contractors, or seasonal employees with known end dates. |
| **Delete** | `userdel -r <user>` | Permanent removal. Use only after data/home backup and handoffs are finalized. `-r` purges the home directory. |

### Orphaned Files (`find / -nouser`)
* Every Linux file is tagged with a numeric UID.
* When a user is deleted without `-r` (or if they created files outside `/home`, such as in `/tmp` or `/srv`), their files remain owned by the orphaned numeric UID.
* `sudo find / -nouser 2>/dev/null` discovers files whose owner UID lacks a corresponding entry in `/etc/passwd`.
* Danger: If that UID is later reassigned by `useradd`, the new user silently inherits ownership of those orphaned files.

### Boss Challenge Pattern: Team Onboarding
* **Directory SGID + Sticky Bit:**
  - Shared folder: `/srv/data` owned by `root:data`.
  - Permissions: `chmod 3770 /srv/data` (or `2770`):
    - `2` (SGID): Files created inside automatically inherit the `data` group rather than the creator's primary group.
    - `1` (Sticky): Users cannot delete or rename files created by other team members.

---

## 3. Lab 05: Processes, Jobs & Priorities (LPI 103.5, 103.6)

### Process Inspection & `/proc`
* **Dialects:**
  - `ps aux` (BSD style): Displays `%CPU`, `%MEM`, `VSZ`, `RSS`, `STAT`, `COMMAND`.
  - `ps -ef` (System V style): Explicitly displays `PPID` (Parent Process ID) column.
  - Tree views: `ps -ef --forest`, `ps auxf`, `pstree -p`.
* **PID 1 (systemd):**
  - First userspace process launched by kernel.
  - Adopts orphaned processes whose parents exit before them.
* **The `/proc/<pid>/` Live Kernel Window:**
  - `/proc/<pid>/cmdline`: Full startup command and arguments (null-delimited `\0`).
  - `/proc/<pid>/cwd`: Symbolic link to process's current working directory.
  - `/proc/<pid>/environ`: Exported environment variables (null-delimited `\0`).
  - `/proc/<pid>/fd/`: Directory of open file descriptors (0=stdin, 1=stdout, 2=stderr, sockets).

### Metrics: Load Average & Memory
* **Load Average (`uptime`, `top`):**
  - Absolute count of runnable processes (actively using CPU or waiting in run queue/uninterruptible disk I/O).
  - Interpretation depends on core count:
    - On a **2-vCPU** host: Load `2.0` = 100% capacity. Load `4.0` = 200% capacity (heavy queueing/backlog).
    - On a **16-vCPU** host: Load `4.0` = ~25% capacity (4 busy cores, 12 idle cores). Full capacity = `16.0`.
* **Memory (`free -h`):**
  - **`available`:** The metric that matters. Kernel's estimate of memory available for new applications without swapping, including reclaimable page cache.
  - High `buff/cache` is healthy; unused RAM is actively leveraged for filesystem cache and released instantly when needed.

### Linux Signals
| Signal | Number | Catchable? | Purpose & Behavioral Impact |
|---|:---:|:---:|---|
| **SIGHUP** | 1 | Yes | Controlling terminal closed (kills background child unless protected). Daemons (nginx, sshd) repurpose it to reload configs without restarting. |
| **SIGINT** | 2 | Yes | Interactive interrupt sent via `Ctrl+C`. Request to cancel/stop. |
| **SIGKILL** | 9 | **No** | Immediate termination enforced by kernel. Process cannot clean up buffers or connections (risk of data corruption). |
| **SIGTERM** | 15 | Yes | Polite termination request. Allows process to flush buffers, close files, and exit cleanly. |
| **SIGSTOP** | 19 | **No** | Pauses/freezes process execution (`STAT` code becomes `T`). Cannot be ignored. |
| **SIGCONT** | 18 | Yes | Resumes a stopped process (`STAT` code returns to `S` or `R`). |

### Shell Job Control & Session Persistence
* **Jobs:**
  - `Ctrl+Z` suspends foreground job.
  - `bg %1` sends suspended job to background.
  - `fg %1` brings background job to foreground.
  - `jobs` lists active shell jobs.
* **Disconnect Fixes:**
  - `nohup <cmd> &`: Ignores `SIGHUP` and redirects stdout/stderr to `nohup.out`. Non-interactive once detached.
  - `screen`: Detach with `Ctrl+A, D`, reconnect with `screen -r`.
  - `tmux`: Detach with `Ctrl+B, D`, reconnect with `tmux attach -t <session>`. Preserves persistent interactive session across SSH drops.

### Niceness & Scheduling Priorities
* Range: `-20` (highest priority / least nice) to `19` (lowest priority / most nice). Default is `0`.
* **"Nice" Orientation:**
  - Niceness `19` is "nice" to *other* processes because it readily yields CPU time.
  - Niceness `-20` is aggressive, demanding CPU priority ahead of other tasks.
* **Permission Rule:** Normal unprivileged users can only *increase* niceness (make their tasks friendlier). Only `root` can lower niceness or grant negative niceness (to prevent CPU starvation).
* **Contention Demonstration:**
  - Two `yes > /dev/null` processes on a 2-vCPU box will each take 100% of a core without contention.
  - To demonstrate niceness scheduling in `top`, pin both burners to the same core using `taskset -pc 0 <PID>` to force scheduler arbitration.

### Boss Challenge: Runaway Process Incident Drill
* **Triage Sequence:**
  1. Detect: Check `uptime` and `top`.
  2. Identify: `ps aux --sort=-%cpu | head` and locate parent script.
  3. Map: `pstree -p <parent_pid>`.
  4. Throttle (Breathing Room): `renice -n 19 -p <pids>` immediately cools CPU contention.
  5. Clean Kill: `pkill -P <parent_pid>` (kill children) then `kill <parent_pid>` (kill parent).
  6. Verify: Confirm `ps aux | grep yes` is clear and load average declines in `uptime`.
* **Incident Report Structure:**
  - Line 1: **Symptom** (high load average, pegged CPU).
  - Line 2: **Diagnosis** (runaway CPU saturation caused by specific workload).
  - Line 3: **Commands** (exact commands used).
  - Line 4: **Resolution** (deprioritization, clean termination, load return to normal).
  - Line 5: **Verification** (`uptime` and `ps` confirmations).

---

## 4. Common PR Review Pitfalls to Check

1. **Hash Prefix Claims:** Always cross-reference the pasted `/etc/shadow` hash string ($6$ = SHA-512, $y$ = yescrypt) against the author's written explanation.
2. **System User Flag:** Ensure `useradd -r -M` is used (not `-m`, which creates a home directory).
3. **Runbook Inline Reasons:** Ensure every command in multi-step runbooks includes an inline comment explaining its role.
4. **Diagnosis Precision:** Confirm that CPU-bound runaway scripts (`yes > /dev/null`) are diagnosed as CPU saturation, not memory leaks or OOM.
5. **Load Averages vs Cores:** Reject explanations claiming load 4.0 on 16 vCPUs is "100% utilized" (it is 25%).
6. **Template Placeholders:** Check for unreplaced template text (`[PID]`, `[real value]`).
7. **Asciinema Runaway Recordings:** Verify that the required asciinema recording captures the runaway drill from start to calm.

---

## 5. Antigravity Prompting Cheat Sheet for Reviews

When opening a new session in Antigravity (on macOS or Windows) to review a lab PR:

```markdown
Review PR <url> against the guidelines in linux-lpi-labs/lab-XX-<topic>.
Follow the review standards and checklist in linux-lpi-labs-review-guide.md:
1. Verify terminal evidence, command completeness, and inline reasons in runbooks.
2. Audit conceptual answers in 'Explain It' for precision.
3. Check for copy-paste glitches, unreplaced template tokens, and missing recordings.
4. Provide a structured review report and ready-to-paste GitHub review markdown.
```
