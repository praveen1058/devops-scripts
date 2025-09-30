# 🛠️ DevOps Utility Scripts

A collection of **Bash scripts** used for day-to-day DevOps and infrastructure tasks. These scripts are designed to automate common activities like EC2 instance management, AMI backups, log rotation, and disk usage monitoring — primarily in **AWS environments**.

> 🔒 These scripts are inspired by real-world work, but rewritten for open sharing. All original company code remains private.

---

## 📁 Scripts Included

| Script | Description |
|--------|-------------|
| `ec2-start-stop.sh` | Start or stop EC2 instances based on instance ID or tags |
| `ami-backup.sh` | Create AMI snapshots of EC2 instances and delete old ones |
| `log-rotate.sh` | Rotate logs in `/var/log/` or application-specific directories |
| `disk-usage-alert.sh` | Send alert if disk usage crosses threshold (e.g., 80%) |
| *(more coming...)* | Jenkins job runners, cron job examples, etc. |

---

## 🚀 Usage

All scripts are Bash-based and can be run on any Linux system with appropriate AWS CLI or system access.

### Example: Run EC2 Start/Stop Script

```bash
chmod +x ec2-start-stop.sh
./ec2-start-stop.sh start i-0123456789abcdef0
