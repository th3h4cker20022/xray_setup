#!/bin/bash
set -e

# Update & install basics
apt update -y
apt install -y curl

# Install Xray
bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

# Stop service before editing
systemctl stop xray

# Create config directory
mkdir -p /usr/local/etc/xray

# Write config
cat > /usr/local/etc/xray/config.json << 'EOF'
{
  "log": {
    "loglevel": "warning"
  },
  "dns": {
    "servers": [
      "8.8.8.8",
      "1.1.1.1"
    ]
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "aa5119ff-6c3e-4081-a8f6-ecad6500a7c0"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": {
          "path": "/discord"
        },
        "tlsSettings": {
          "serverName": "discord.com",
          "alpn": ["http/1.1"],
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/cert.pem",
              "keyFile": "/usr/local/etc/xray/key.pem"
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIP"
      }
    }
  ]
}
EOF

# Write cert
cat > /usr/local/etc/xray/cert.pem << 'EOF'
-----BEGIN CERTIFICATE-----
MIIDDTCCAfWgAwIBAgIUXsm48dfFs3FtSxUxL3FYaU/AfTgwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAwwLZGlzY29yZC5jb20wHhcNMjYwMTIxMTYwMjA4WhcNMjcw
MTIxMTYwMjA4WjAWMRQwEgYDVQQDDAtkaXNjb3JkLmNvbTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAKlDa7Onbn8nhxouoZ7OLMYg7juFIVN51SuB5lfq
kr7OyBX3440CD3AwVFPBYVHTZ9lqMcsDnkgk48xv8pZCIh//PC+IQGepvfzWmBMK
41eaQU+hic0CIsbFLB8N/t1JIINT5c6MjJ1Y6vYL2kQ5PX2s5X8hedw/mjZBIWgA
QfObg20BEglFWJaHeRlFwpRf0Y1OCuLTPW6l39bO1AT2uCwhyQznK+3AIaJ9/NJN
0DNuWA1yu8/CxsncsVwLkjGvyXYyAnXCQcMm1XOG97hnWcbmq6Xv1EZeyRRltPB0
kMGSnJnH63NmfBlnEqOUrUhoTU35mozbf9L0mtPbzRjP8M0CAwEAAaNTMFEwHQYD
VR0OBBYEFNJi82K4T0aCh0EvogXyO/hdsLooMB8GA1UdIwQYMBaAFNJi82K4T0aC
h0EvogXyO/hdsLooMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEB
AE7NR7b/d3B6xNitk96S8y/8hr5qiuY7h9gKbGa3oL3aG5mchFFt/0YXPz5/52Um
pRSd83n5vkJ4eAydiOI69sZIiPyoW+6B2HMDBgHh9XP2inC7vddcegSDyWIJZ4Ru
hHLjMVUD0qzWXjKBMjcoGwzn+TnTsV0acqeAwPiZdqba25fyuzpnOMIQ0A4vylF5
LFfBun99flhNBK2T3Clt/Hlosfv3o36bK2xo74g2HUyJLCDfYm7E56G5+kcBIQ0s
mptYxycIF0gKn5nDOYFkvHXS8ZpEgvs6BL/Oy8qlLa0n042Nsatjw7wmPx+nnp0i
u8s0Wqww0dkzkOwp8gP2hC0=
-----END CERTIFICATE-----
EOF

# Write key
cat > /usr/local/etc/xray/key.pem << 'EOF'
-----BEGIN PRIVATE KEY-----
MIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQCpQ2uzp25/J4ca
LqGezizGIO47hSFTedUrgeZX6pK+zsgV9+ONAg9wMFRTwWFR02fZajHLA55IJOPM
b/KWQiIf/zwviEBnqb381pgTCuNXmkFPoYnNAiLGxSwfDf7dSSCDU+XOjIydWOr2
C9pEOT19rOV/IXncP5o2QSFoAEHzm4NtARIJRViWh3kZRcKUX9GNTgri0z1upd/W
ztQE9rgsIckM5yvtwCGiffzSTdAzblgNcrvPwsbJ3LFcC5Ixr8l2MgJ1wkHDJtVz
hve4Z1nG5qul79RGXskUZbTwdJDBkpyZx+tzZnwZZxKjlK1IaE1N+ZqM23/S9JrT
280Yz/DNAgMBAAECgf8lVohIEhHVCRT2OLa1dPBdUp865Y3tVQgqCa94GOpUV6yg
8xT/N9GTkYd6ZCca0HJmX/FU3nBaTx5Ggd0zVnGUOc7NAsiHo8aFP9FaYgVg8Um+
FWt0DdLIvxmR3JnVC/5gFnAF7nsyyMcL/7wCtEhxlEeaIDMBhngFVS4QdOGlxbZ7
owao0okrZZ6vd3w5dSsEIlsrM6SRUJ2VRdlON7Hcmi7F/CBh4kJFTj6fKHNnU4VD
Xq2/w6PFzhMsq+qluqqhoAN6GLaJHwNzrE1RvV5uY3INfZimLdHID24unIr9fFgE
vufbMP+pLepm9s3EBG7Hn7/mBs7Jgg0LDg84jqkCgYEAtxFFLAOLwR5NCr2khIV/
1widf70xJ3/5SJOiaFa/7muASsqmXeFAZ6CjkCzZdOfFNA1SnC7CNAHwT8On32Ig
Z7JT/z/P/uRq4VsR5S5zDwV3Uyf4sK448Kv9Pt62guK6QacCgLH7TfdQMGrkff/6
/lOpk5auUZP2M7zqkG4x2ekCgYEA7LJLaMWP6FktqQrF3h6/eXDPF4/mr5h7qHjx
zCjQKPfSx3rJwi806wvCrnSIzhvwgSfIvsJg53w+KojKirT1l8nZU3btPp6Cj+iE
Spvl1uNGWaPn20+gww3pU5ntIvE50OsPzYUqW8HVTyb5i4y7fPpOon/RE+QoUDEI
MXfYbUUCgYBw179oowLpVlEs9rrLSTMFDHVxAOCktXimqQIqCJckUrVw5LtqEOfP
OLC5tTuRmS/wpumuBhCFWFCWCkeXJXhOExk9tEr0lj3fjXBZcalQsBDefDwKREoq
6AkhUMz1nuYqg9TCGXOLmo+eWLVhiYFgdZeItw/ajzbqq193CcXGyQKBgQDau20q
dh+ltPuYEmeF+14wiIooGQgyTzQ/HP0+EJ1ErrfvNc5LD7rUVvriorhl17XqdOxz
NEe+w7bjMaQSiGXIjnSyR924F11KRbIzDFxat46kee5iYfSLLEjpw/47YzZtlTv2
TdA2GSrZSYgkaLo+JUYTrxB0VEzYxmbu5/RuDQKBgHf40RkrBvuJq+cTuN+tJIpV
m/7/RiyyowVoB/VE38SFwki9txklHMB4NUhnxLCXuujf1qyJpmP8heTqJNN5eJoR
5mBcbnBCRj74wwr99hgbJL7IORNvqT0H1fSB+Bs/KtYs/X9mnQ7aL363PSqIFFTu
afzqwyOHIfzbLD7gT5xU
-----END PRIVATE KEY-----
EOF

# ✅ FIX PERMISSIONS (important)
chown -R root:xray /usr/local/etc/xray
chmod 750 /usr/local/etc/xray
chmod 640 /usr/local/etc/xray/key.pem
chmod 644 /usr/local/etc/xray/cert.pem
chmod 644 /usr/local/etc/xray/config.json

# -------------------
# 🔥 Firewall setup
# -------------------

apt install -y ufw

ufw default deny incoming
ufw default allow outgoing

# Safer than hardcoding port 22
ufw allow OpenSSH

# Xray port
ufw allow 443/tcp

ufw --force enable

# -------------------

# Enable & start Xray
systemctl enable xray
systemctl restart xray

echo "✅ Xray + Firewall ready"
