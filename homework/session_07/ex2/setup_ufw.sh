#!/usr/bin/env bash
# ==============================================================================
# Script cấu hình tường lửa UFW cho Bài 2 (Session 07)
# ==============================================================================

set -e

echo "[+] Thiết lập chính sách mặc định..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "[+] Cho phép các cổng dịch vụ công khai..."
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP (Nginx)
sudo ufw allow 8082/tcp  # Spring Boot

# Chú ý: Cổng MySQL (3306) không được mở (bị chặn mặc định bởi default deny)

echo "[+] Kích hoạt UFW..."
sudo ufw --force enable

echo "[+] Kiểm tra trạng thái UFW:"
sudo ufw status verbose
