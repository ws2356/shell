#!/usr/bin/env bash
set -e

if [ "$(id -u)" -eq 0 ] ; then
  echo "Must not be called as root as required by homebrew."
fi

user=$(id -nu)
label=${1:-${user}.homebrew.auto_update}
plist_file=/Library/LaunchDaemons/"$label".plist
log_file=/var/log/"${label}".log
error_file=/var/log/"${label}".error.log

if [ -f "$plist_file" ] ; then
  if ! command xmlstarlet >/dev/null 2>&1 ; then
    brew install xmlstarlet
  fi
  existing_label=$(xmlstarlet sel -T -t \
    -v '//dict/key[text()="Label"]/following-sibling::*[1]' "$plist_file" \
    2>/dev/null)
  if [ -n "$existing_label" ] && launchctl list "$existing_label" >/dev/null 2>&1 ; then
    echo "Existing plist file is valid, you should unload it beforehand."
    exit 1
  fi
fi

# plist 文件不能包含下面三个字符，否则需要转译\`$
sudo tee "$plist_file" <<EOFPLIST
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

sudo chown "$(sudo id -nu):$(sudo id -ng)" "$plist_file"
chmod 644 "$plist_file"

sudo touch "$error_file"
sudo chown "$(id -nu):$(id -ng)" "$_"
sudo chmod 644 "$_"

sudo touch "$log_file"
sudo chown "$(id -nu):$(id -ng)" "$_"
sudo chmod 644 "$_"

if ! sudo launchctl load "$plist_file" ; then
  echo "Failed to load plist_file: $plist_file"
fi

if ! grep -E '^[^#]*HOMEBREW_NO_AUTO_UPDATE' ~/.bash_profile >/dev/null 2>&1 ; then
  echo 'export HOMEBREW_NO_AUTO_UPDATE=1' >> ~/.bash_profile
fi
