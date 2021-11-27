[Unit]
Description=Slack Export Viewer Web UI
After=network.target

[Service]
User=slack
Type=simple
ExecStart=/home/slack/.local/bin/slack-export-viewer -z /home/slack/latest-export.zip --no-browser --ip m4_getenv_req(WIREGUARD_NATHAN_IP) --port m4_getenv_req(SLACK_EXPORT_VIEWER_PORT)

[Install]
WantedBy=multi-user.target
