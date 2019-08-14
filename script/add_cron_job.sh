crontab -l > cron_backup
repeat_hour=$((2 + RANDOM%3))   # To add some randomness in hours
cmd="cd /var/hda/platform/html && rake friendings:update_friend_users"
echo "0 */$repeat_hour * * * $cmd" >> cron_backup
crontab cron_backup
rm cron_backup
