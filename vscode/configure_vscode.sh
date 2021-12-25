#!/usr/bin/env bash

main() {
    # Install all needed VS code extensions.
    install_extensions
    # Add custom user settings to VS code.
    configure_settings
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
        # Theme
        code --install-extension dracula-theme.theme-dracula
        code --install-extension pkief.material-icon-theme
        fi
}

function configure_settings() {
    cp ./settings.json $HOME/Library/Application\ Support/Code/User/settings.json
}

main "$@"
