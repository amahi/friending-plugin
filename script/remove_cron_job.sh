crontab -l | grep -v 'cd /var/hda/platform/html && rake friendings:update_friend_users' | crontab -
