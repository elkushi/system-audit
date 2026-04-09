#!/bin/bash

# ============================================
# Linux System Security Audit Tool
# Author: Moustafa Elkushi
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

OUTPUT="audit_report_$(date +%Y%m%d_%H%M%S).txt"

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_bad()  { echo -e "${RED}[CRITICAL]${NC} $1"; }

{
echo "================================================"
echo "  LINUX SECURITY AUDIT REPORT"
echo "  Date: $(date)"
echo "  Host: $(hostname)"
echo "  User: $(whoami)"
echo "================================================"

# ---- SYSTEM INFO ----
print_header "SYSTEM INFORMATION"
echo "OS:      $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
echo "Kernel:  $(uname -r)"
echo "Uptime:  $(uptime -p)"
echo "CPU:     $(nproc) cores"
echo "RAM:     $(free -h | grep Mem | awk '{print $2}')"
echo "Disk:    $(df -h / | tail -1 | awk '{print $4}') free"

# ---- USERS ----
print_header "USER SECURITY"
echo "--- Users with shell access ---"
grep -E "/bash|/sh|/zsh" /etc/passwd | cut -d: -f1

echo ""
echo "--- Sudo users ---"
getent group sudo | cut -d: -f4

echo ""
echo "--- Users with empty passwords ---"
EMPTY=$(sudo awk -F: '($2 == "" ) { print $1}' /etc/shadow 2>/dev/null)
if [ -z "$EMPTY" ]; then
    print_ok "No users with empty passwords"
else
    print_bad "Users with empty passwords: $EMPTY"
fi

echo ""
echo "--- Last logins ---"
last | head -10

# ---- SUID FILES ----
print_header "SUID/SGID FILES (Privilege Escalation Risk)"
echo "--- SUID files ---"
SUID=$(find / -perm -4000 2>/dev/null)
if [ -z "$SUID" ]; then
    print_ok "No SUID files found"
else
    print_warn "SUID files found:"
    echo "$SUID"
fi

# ---- NETWORK ----
print_header "NETWORK & OPEN PORTS"
echo "--- Open ports ---"
ss -tulpn 2>/dev/null | grep LISTEN

echo ""
echo "--- Network interfaces ---"
ip a | grep "inet " | awk '{print $2, $NF}'

echo ""
echo "--- Active connections ---"
ss -tn | grep ESTABLISHED | head -10

# ---- PROCESSES ----
print_header "RUNNING PROCESSES"
echo "--- Top 10 CPU processes ---"
ps aux --sort=-%cpu | head -11

echo ""
echo "--- Root processes ---"
ps aux | grep "^root" | grep -v grep | awk '{print $11}' | head -10

# ---- CRON JOBS ----
print_header "SCHEDULED TASKS (Cron Jobs)"
echo "--- System crontab ---"
cat /etc/crontab 2>/dev/null

echo ""
echo "--- Cron directories ---"
ls -la /etc/cron* 2>/dev/null

echo ""
echo "--- Current user crons ---"
crontab -l 2>/dev/null || echo "No crontab for current user"

# ---- FILE PERMISSIONS ----
print_header "SENSITIVE FILE PERMISSIONS"
FILES=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/sudoers"
    "/etc/ssh/sshd_config"
    "~/.ssh/authorized_keys"
)

for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        PERM=$(stat -c "%a %U %G" $FILE)
        echo "$FILE → $PERM"
    fi
done

# ---- SSH CONFIG ----
print_header "SSH CONFIGURATION"
SSHD="/etc/ssh/sshd_config"
if [ -f "$SSHD" ]; then
    echo "--- Key SSH settings ---"
    grep -E "^PermitRootLogin|^PasswordAuthentication|^Port|^PubkeyAuthentication|^PermitEmptyPasswords" $SSHD 2>/dev/null

    ROOT_LOGIN=$(grep "^PermitRootLogin" $SSHD | awk '{print $2}')
    PASS_AUTH=$(grep "^PasswordAuthentication" $SSHD | awk '{print $2}')

    [ "$ROOT_LOGIN" = "yes" ] && print_bad "Root login is ENABLED!" || print_ok "Root login disabled"
    [ "$PASS_AUTH" = "yes" ] && print_warn "Password auth enabled (prefer key-only)" || print_ok "Password auth disabled"
fi

# ---- INSTALLED PACKAGES ----
print_header "RECENTLY INSTALLED PACKAGES"
grep " install " /var/log/dpkg.log 2>/dev/null | tail -10

# ---- LOG FILES ----
print_header "RECENT AUTHENTICATION LOGS"
echo "--- Failed login attempts ---"
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10 || \
grep "Failed password" /var/log/secure 2>/dev/null | tail -10 || \
echo "No failed attempts found or no access to auth log"

echo ""
echo "--- Successful logins ---"
grep "Accepted" /var/log/auth.log 2>/dev/null | tail -5 || \
echo "No log access"

# ---- SUMMARY ----
print_header "AUDIT COMPLETE"
echo "Report saved to: $OUTPUT"
echo "Date: $(date)"

} | tee "$OUTPUT"

echo ""
echo -e "${GREEN}Audit complete! Report saved to: $OUTPUT${NC}"
