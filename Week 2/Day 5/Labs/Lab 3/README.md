# Lab 7 — Shell Scripting Ops Toolkit

## Overview

In this lab, I practiced writing shell scripts for common system administration tasks. I worked on file management, process monitoring, backups, log parsing, and cron scheduling. The lab helped me understand how shell scripts can automate repetitive tasks and make system operations easier to manage.

## Scripts

* `common.sh` — contains shared helper functions for logging, dependency checks, and error handling
* `fm_tool.sh` — finds files based on pattern and age, archives them, and applies retention
* `proc_watch.sh` — monitors processes by name and logs CPU/memory usage
* `backup.sh` — creates timestamped backups, verifies them, and keeps only the latest ones
* `log_parse.sh` — parses log files and creates summary output files

## Commands I ran

### File management

```bash
"$HOME/lab7/scripts/fm_tool.sh" --dir "$HOME/lab7/demo" --pattern '*.log' --older-than 0 --archive --retention 3
```

### Process monitoring

```bash
(sleep 120 &) ; "$HOME/lab7/scripts/proc_watch.sh" --name 'sleep' --samples 3 --interval 1
```

### Backup

```bash
"$HOME/lab7/scripts/backup.sh" --source "$HOME/lab7" --dest "$HOME/lab7-outputs" --name lab7 --exclude tmp --retention 3
```

### Log parsing

```bash
"$HOME/lab7/scripts/log_parse.sh" --file /var/log/syslog --type syslog --out "$HOME/lab7-outputs" || true
```

### Cron export

```bash
crontab -l | tee "$HOME/lab7-outputs/lab7-cron.txt"
```

## Observations

* `common.sh` worked correctly and wrote log messages into `lab7.log`
* `fm_tool.sh` created archive files inside `lab7-outputs`
* `proc_watch.sh` logged the running `sleep` process successfully
* `backup.sh` created backup archives and verified them
* `log_parse.sh` created summary files such as `top-programs.txt` and `top-error-times.txt`
* the cron entries were exported into `lab7-cron.txt`

## Challenges

One challenge I faced was with `fm_tool.sh`. In the original lab code, `find -mtime +0` only matches files older than 24 hours. Because of that, the new `.log` files I created during testing were not being matched. I had to adjust the script so that `--older-than 0` would work for newly created files.

Another small issue happened in `proc_watch.sh`. The lab example used `sleep\b` as the pattern, but it did not match correctly in my environment. I changed it to just `sleep`, and after that the script worked as expected.

I also noticed that log file locations can depend on the system, so this part may behave a little differently on different Linux environments.

## Changes I made

I made a few small changes so the scripts would work correctly in my environment.

In `fm_tool.sh`, I changed the file matching logic so `--older-than 0` includes new files created during testing. I also adjusted the archive command so it archives only the matched files.

In `proc_watch.sh`, I used `sleep` instead of `sleep\b` for testing because that matched correctly and produced the required log output.

These were small practical fixes, but they helped me complete the lab and understand better how the scripts work.
