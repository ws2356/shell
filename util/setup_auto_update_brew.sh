#!/usr/bin/env bash
set -e

label=${1:-work.mac.brew.update}
plist_file=~/Library/LaunchAgents/"$label".plist
log_file=/var/log/"${label}".log
error_file=/var/log/"${label}".error.log
user=$(id -nu)

# plist 文件不能包含下面三个字符，否则需要转译\`$
cat >"$plist_file" <<EOFPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>KeepAlive</key>
	<dict>
		<key>SuccessfulExit</key>
		<false/>
	</dict>
	<key>Label</key>
	<string>${label}</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/bin/brew</string>
		<string>update</string>
	</array>
	<key>RunAtLoad</key>
	<false/>
	<key>StandardErrorPath</key>
	<string>${error_file}</string>
	<key>StandardOutPath</key>
	<string>${log_file}</string>
	<key>UserName</key>
	<string>${user}</string>
        <key>ExitTimeOut</key>
        <integer>3599</integer>
        <key>StartInterval</key>
        <integer>3600</integer>
</dict>
</plist>
EOFPLIST

chmod 644 "$plist_file"

sudo touch "$error_file"
sudo chown "$(id -nu):$(id -ng)" $_
sudo touch "$log_file"
sudo chown "$(id -nu):$(id -ng)" $_

if ! launchctl load "$plist_file" ; then
  echo "Failed to load plist_file: $plist_file"
fi
