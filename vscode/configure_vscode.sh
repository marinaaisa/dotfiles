#!/usr/bin/env bash

main() {
    open_vscode_command_palette
    # Install all needed VS code extensions.
    install_extensions
    # Add custom user settings to VS code.
    configure_settings
}

function open_vscode_command_palette() {
# Open the Command Palette in VS Code
osascript -e 'tell application "Visual Studio Code" to activate'
osascript -e 'tell application "System Events" to keystroke "p" using {command down, shift down}'

# Type 'shell command' and press Enter
osascript -e 'tell application "System Events" to keystroke "shell command"'
osascript -e 'tell application "System Events" to keystroke return'
}

function install_extensions() {
    code -v > /dev/null
    if [[ $? -eq 0 ]];then
        # Javascript
        code --install-extension dbaeumer.vscode-eslint
        code --install-extension esbenp.prettier-vscode

        # Vue
        code --install-extension octref.vetur
        code --install-extension hollowtree.vue-snippets

        # HTML
        code --install-extension bradgashler.htmltagwrap
        code --install-extension formulahendry.auto-close-tag
        code --install-extension formulahendry.auto-rename-tag
        # Utils
        code --install-extension streetsidesoftware.code-spell-checker
        code --install-extension cssho.vscode-svgviewer
        code --install-extension donjayamanne.githistory
        code --install-extension eamodio.gitlens
        code --install-extension zainchen.json
        code --install-extension pflannery.vscode-versionlens
        code --install-extension editorconfig.editorconfig
        code --install-extension yzhang.markdown-all-in-one
        code --install-extension formulahendry.code-runner
        code --install-extension stkb.rewrap
        # Theme
        code --install-extension sdras.night-owl
        code --install-extension pkief.material-icon-theme
        fi
}

function configure_settings() {
    cp ./settings.json $HOME/Library/Application\ Support/Code/User/settings.json
}

main "$@"
