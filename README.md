## Requirements

```
sudo apt-get install python-openssl
sudo pip install requests[security]
```

If you want to use Amazon S3  
```
sudo pip install s3cmd
```

If you want to use Backblaze B2  
```
sudo pip install b2
```

## Usage

Clone the repo:

```
git clone https://github.com/SergeyCherepanov/backup-tool.git /opt/backup-tool
```

* rename config.sh.dist to config.sh and update credentials  
* rename list-include.txt.dist to list-include.txt and update path  
* rename list-exclude.txt.dist to list-exclude.txt and update path  

Ddd cron job:

```
0 0 * * * /opt/backup-tool/backup-db.sh && /opt/backup-tool/backup-fs.sh
```
