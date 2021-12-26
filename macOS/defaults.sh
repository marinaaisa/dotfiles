#!/usr/bin/env bash

main() {
    configure_system
    configure_finder
    configure_app_store
    configure_3rd_party
}

function add_app_to_dock {
    app="${1}"

    if open -Ra "${app}"; then
        echo "$app added to the Dock."

        defaults write com.apple.dock persistent-apps -array-add "<dict>
                <key>tile-data</key>
                <dict>
                    <key>file-data</key>
                    <dict>
                        <key>_CFURLString</key>
                        <string>${app}</string>
                        <key>_CFURLStringType</key>
                        <integer>0</integer>
                    </dict>
                </dict>
            </dict>"
    else
        echo "ERROR: Application $1 not found."
    fi
}

function configure_system() {
    LOGIN_HOOK_PATH=~/dotfiles/macOS/login_hook_script.sh
    LOGOUT_HOOK_PATH=~/dotfiles/macOS/logout_hook_script.sh

    PRIMARY_CLOUDFLARE_DNS_ADDRESS="1.1.1.1"
    SECONDARY_CLOUDFLARE_DNS_ADDRESS="1.0.0.1"
    FIRST_REDUNDANT_CLOUDFLARE_DNS_ADDRESS="2606:4700:4700::1111"
    SECOND_REDUNDANT_CLOUDFLARE_DNS_ADDRESS="2606:4700:4700::1001"

    # Update DNS servers to Cloudflare's servers https://one.one.one.one/dns/
    networksetup -setdnsservers Wi-Fi $PRIMARY_CLOUDFLARE_DNS_ADDRESS $SECONDARY_CLOUDFLARE_DNS_ADDRESS $FIRST_REDUNDANT_CLOUDFLARE_DNS_ADDRESS $SECOND_REDUNDANT_CLOUDFLARE_DNS_ADDRESS

    # Enable tap to click
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    # Disable macOS startup chime sound
    sudo defaults write com.apple.loginwindow LoginHook $LOGIN_HOOK_PATH
    sudo defaults write com.apple.loginwindow LogoutHook $LOGOUT_HOOK_PATH
    # Configure keyboard repeat https://apple.stackexchange.com/a/83923/200178
    defaults write -g InitialKeyRepeat -int 15
    defaults write -g KeyRepeat -int 2
    # Disable auto-correct
    defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
    # Enable full keyboard access for all controls which enables Tab selection in modal dialogs
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    # Don't show Siri in the menu bar
    defaults write com.apple.Siri StatusMenuVisible -bool false

    # Show volume in the menu bar
    defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.volume" -int 1

    ###############################################################################
    # Dock
    ###############################################################################
    defaults write com.apple.dock "orientation" -string "left"
    defaults write com.apple.dock persistent-apps -array
    defaults write com.apple.dock "tilesize" -int "40"
    defaults write com.apple.dock "show-recents" -bool "false"

    declare -a apps=(
        '/Applications/1Password 7.app'
        '/System/Applications/Notes.app'
        '/Applications/Todoist.app'
        '/Applications/iTerm.app'
        '/Applications/Visual Studio Code.app'
        '/Applications/Google Chrome.app'
        '/Applications/Spotify.app'
        '/Applications/Anki.app'
    );

    for app in "${apps[@]}"; do
        add_app_to_dock "$app"
    done

    # Apply Dock changes
    killall Dock

    # Hide airplay menu item
    defaults write com.apple.airplay showInMenuBarIfPresent -bool false

    # Show battery percentage in menu bar
    defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.battery" -bool true
    defaults write com.apple.menuextra.battery '{ ShowPercent = YES; }'

    # Disable the “Are you sure you want to open this application?” dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Expand save panel by default
    defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
    defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true

    # Restart automatically if the computer freezes
    sudo systemsetup -setrestartfreeze on

    ###############################################################################
    # 💻 Trackpad
    ###############################################################################

    # Enable tap to click for the current user and the login screen. (Don't have to press down on the trackpad -- just tap it.)
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
    defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
    defaults write -g com.apple.mouse.tapBehavior -int 1

    # Trackpad: map two fingers tap to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write -g com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write -g com.apple.trackpad.enableSecondaryClick -bool true
    defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -int 1
}

function configure_finder() {
    # Save screenshots to Downloads folder
    defaults write com.apple.screencapture location -string "${HOME}/Downloads"
    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    # Set Downloads as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTarget -string "PfLo"
    defaults write com.apple.finder NewWindowTargetPath -string \
        "file://${HOME}/Downloads/"
    # disable status bar
    defaults write com.apple.finder ShowStatusBar -bool false
    # disable path bar
    defaults write com.apple.finder ShowPathbar -bool false
    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    # Disable disk image verification
    defaults write com.apple.frameworks.diskimages \
        skip-verify -bool true
    defaults write com.apple.frameworks.diskimages \
        skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages \
        skip-verify-remote -bool true
    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
    # Stop Photos from opening automatically   
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
    # Adding ‘Quit’ option to Finder 
    defaults write com.apple.finder QuitMenuItem -bool true; killall Finder
    # Display the file extensions in Finder
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true; killall Finder
    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    # Disable screenshot preview thumbnails
    defaults write com.apple.screencapture show-thumbnail -bool FALSE
    # Use column view in all Finder windows by default
    # Four-letter codes for the other view modes: 'icnv', 'clmv', 'Flwv'
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
}

function configure_app_store() {
    # Check for software updates daily, not just once per week
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

    # Download newly available updates in background
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

    # Install System data files & security updates
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
}

function configure_3rd_party () {
    # Spotify - thinks it's super important and should always be started on login. Fuck that.
    mkdir -p ~/Library/Application\ Support/Spotify
    touch ~/Library/Application\ Support/Spotify/prefs
    echo 'app.autostart-mode="off"' >> ~/Library/Application\ Support/Spotify/prefs
    echo 'app.autostart-banner-seen=true' >> ~/Library/Application\ Support/Spotify/prefs

    # iTerm - Yes to update new versions
    defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool true
}

main "$@" 
