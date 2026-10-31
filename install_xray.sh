        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": { "path": "/discord" },
        "tlsSettings": {
          "serverName": "discord.com",
          "alpn": ["http/1.1"],
          "certificates": [{
            "certificateFile": "/usr/local/etc/xray/cert.pem",
            "keyFile": "/usr/local/etc/xray/key.pem"
          }]
        }
      }
    }
  ],
  "outbounds": [{ "protocol": "freedom", "settings": { "domainStrategy": "UseIP" } }]
}
EOF

# Supply your TLS certificate and private key as local files on the VPS.
# Example: CERT_SOURCE=/root/cert.pem KEY_SOURCE=/root/key.pem bash install_xray_fixed.sh
# Do not hardcode private keys in an installer or commit them to source control.
CERT_SOURCE="${CERT_SOURCE:-/root/cert.pem}"
KEY_SOURCE="${KEY_SOURCE:-/root/key.pem}"

if [[ ! -s "$CERT_SOURCE" || ! -s "$KEY_SOURCE" ]]; then
  echo 'ERROR: Missing certificate or private key.' >&2
  echo "Place your certificate at $CERT_SOURCE and private key at $KEY_SOURCE" >&2
  echo 'Or provide CERT_SOURCE and KEY_SOURCE environment variables.' >&2
  exit 1
fi

# Copy before changing ownership: no recursive chown of unrelated files.
if [[ "$CERT_SOURCE" != /usr/local/etc/xray/cert.pem ]]; then
  install -o root -g xray -m 640 "$CERT_SOURCE" /usr/local/etc/xray/cert.pem
fi
if [[ "$KEY_SOURCE" != /usr/local/etc/xray/key.pem ]]; then
  install -o root -g xray -m 640 "$KEY_SOURCE" /usr/local/etc/xray/key.pem
fi

# Critical fix: the official systemd service runs as User=xray, Group=xray.
chown root:xray /usr/local/etc/xray /usr/local/etc/xray/config.json /usr/local/etc/xray/cert.pem /usr/local/etc/xray/key.pem
chmod 750 /usr/local/etc/xray
chmod 640 /usr/local/etc/xray/config.json /usr/local/etc/xray/cert.pem /usr/local/etc/xray/key.pem

# Verify config readability and syntax under the service user.
runuser -u xray -- /usr/local/bin/xray run -test -config /usr/local/etc/xray/config.json

# Preserve SSH access: verify an SSH allow rule is present before enabling UFW.
ufw default deny incoming
ufw default allow outgoing
if ufw app info OpenSSH >/dev/null 2>&1; then
  ufw allow OpenSSH
else
  ufw allow 22/tcp
fi
ufw allow 443/tcp
ufw --force enable

systemctl enable xray
systemctl restart xray
systemctl is-active --quiet xray

# Check the listening socket before reporting success.
if ! ss -tlnp | grep -Eq '(:443)[[:space:]]'; then
  echo 'ERROR: Xray is active but port 443 is not listening.' >&2
  exit 1
fi

echo '✅ Xray is running and TCP port 443 is listening.'
echo '⚠️ Your current self-signed discord.com certificate is not publicly trusted. Replace it with a certificate for a domain you control.'

echo "✅ Xray + Firewall ready"
