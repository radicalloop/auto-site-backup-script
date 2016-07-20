# auto-site-backup-script
Shell script to take automatic backups of code and database on same server and remote server

Just set your values in the variables at top,

and set up the cron job to run the shell script at desired intervals,

like:
`30 23 * * * /path/to/backup.sh`

to take automatic backups of code and db everyday at 11:30 PM.
