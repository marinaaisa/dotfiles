#!/usr/bin/env bash

PROJECTS_REPO=~/Projects
DOTFILES_REPO=${PROJECTS_REPO}/dotfiles

main() {
    # Required to install packages
    ask_for_sudo
    install_xcode_command_line_tools
    # Gets dotfiles latest repo from master branch
    clone_dotfiles_repo
    # To manage packages
    install_homebrew
    install_packages_with_brewfile
    change_shell_to_fish
    setup_symlinks
    update_hosts_file
    setup_macOS_defaults
    configure_vscode
}

function ask_for_sudo() {
    info "Prompting for sudo password"
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; \
            sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
        success "Sudo credentials updated"
    else
        error "Obtaining sudo credentials failed"
        exit 1
    fi
}

function install_xcode_command_line_tools() {
    info "Installing Xcode command line tools"

    if softwareupdate --history | grep --silent "Command Line Tools"; then
        success "Xcode command line tools already exists"
    else
        xcode-select --install
        while true; do
            if softwareupdate --history | grep --silent "Command Line Tools"; then
                success "Xcode command line tools installation succeeded"
                break
            else
                substep "Xcode command line tools still installing..."
                sleep 20
            fi
        done
    fi
}

function clone_dotfiles_repo() {
    info "Cloning dotfiles repository into ${DOTFILES_REPO}"
    if test -e $DOTFILES_REPO; then
        substep "${DOTFILES_REPO} already exists"
        pull_latest $DOTFILES_REPO
        success "Pull successful in ${DOTFILES_REPO} repository"
    else
        url=https://github.com/marinaaisa/dotfiles.git
        if git clone "$url" $DOTFILES_REPO; then
            success "Cloned into ${DOTFILES_REPO}"
        else
            error "Cloning into ${DOTFILES_REPO} failed"
            exit 1
        fi
    fi
}

function pull_latest() {
    substep "Pulling latest changes in ${1} repository"
    if git -C $1 pull origin master &> /dev/null; then
        return
    else
        error "Please pull the latest changes in ${1} repository manually"
    fi
}

function install_homebrew() {
    info "Installing Homebrew"
    if hash brew 2>/dev/null; then
        success "Homebrew already exists"
    else
        url=https://raw.githubusercontent.com/Homebrew/install/master/install
        if yes | /usr/bin/ruby -e "$(curl -fsSL ${url})"; then
            success "Homebrew installation succeeded"
        else
            error "Homebrew installation failed"
            exit 1
        fi
    fi
}

function install_packages_with_brewfile() {
    info "Installing Brewfile packages"

    TAP=${DOTFILES_REPO}/brew/Brewfile_tap
    BREW=${DOTFILES_REPO}/brew/Brewfile_brew
    CASK=${DOTFILES_REPO}/brew/Brewfile_cask
    MAS=${DOTFILES_REPO}/brew/Brewfile_mas

    if hash parallel 2>/dev/null; then
        substep "parallel already exists"
    else
        if brew install parallel &> /dev/null; then
            printf 'will cite' | parallel --citation &> /dev/null
            substep "parallel installation succeeded"
        else
            error "parallel installation failed"
            exit 1
        fi
    fi

    if (echo $TAP; echo $BREW; echo $CASK; echo $MAS) | parallel --verbose --linebuffer -j 4 brew bundle check --file={} &> /dev/null; then
        success "Brewfile packages are already installed"
    else
        if brew bundle --file="$TAP"; then
            substep "Brewfile_tap installation succeeded"

            export HOMEBREW_CASK_OPTS="--no-quarantine"
            if (echo $BREW; echo $CASK; echo $MAS) | parallel --verbose --linebuffer -j 3 brew bundle --file={}; then
                success "Brewfile packages installation succeeded"
            else
                error "Brewfile packages installation failed"
                exit 1
            fi
        else
            error "Brewfile_tap installation failed"
            exit 1
        fi
    fi
}

function change_shell_to_fish() {
    info "Fish shell setup"
    if grep --quiet fish <<< "$SHELL"; then
        success "Fish shell already exists"
    else
        user=$(whoami)
        substep "Adding Fish executable to /etc/shells"
        if grep --fixed-strings --line-regexp --quiet \
            "/opt/homebrew/bin/fish" /etc/shells; then
            substep "Fish executable already exists in /etc/shells"
        else
            if echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells > /dev/null;
            then
                substep "Fish executable successfully added to /etc/shells"
            else
                error "Failed to add Fish executable to /etc/shells"
                exit 1
            fi
        fi
        substep "Switching shell to Fish for \"${user}\""
        if sudo chsh -s /opt/homebrew/bin/fish "$user"; then
            success "Fish shell successfully set for \"${user}\""
        else
            error "Please try setting Fish shell again"
        fi
    fi
}

function setup_symlinks() {
    info "Setting up symlinks"

    symlink "fish:functions"   ${DOTFILES_REPO}/fish/functions    ~/.config/fish/functions
    symlink "fish:config.fish" ${DOTFILES_REPO}/fish/config.fish  ~/.config/fish/config.fish
    symlink "fish:plugins"     ${DOTFILES_REPO}/fish/plugins      ~/.config/fish/fish_plugins
    symlink "fish:history"     ${DOTFILES_REPO}/fish/history      ~/.local/share/fish/fish_history

    success "Symlinks successfully setup"

    # Call install_fish_plugins function after Fish plugins installation
    if install_fish_plugins; then
        success "Fish plugins installed"
    else
        error "Fish plugins couldn't be installed"
    fi
}

function symlink() {
    application=$1
    point_to=$2
    destination=$3
    destination_dir=$(dirname "$destination")

    if test ! -e "$destination_dir"; then
        substep "Creating ${destination_dir}"
        mkdir -p "$destination_dir"
    fi
    if rm -rf "$destination" && ln -s "$point_to" "$destination"; then
        substep "Symlinking for \"${application}\" done"
    else
        error "Symlinking for \"${application}\" failed"
        exit 1
    fi
}

function update_hosts_file() {
    info "Updating /etc/hosts"
    own_hosts_file_path=${DOTFILES_REPO}/hosts/own_hosts
    ignored_keywords_path=${DOTFILES_REPO}/hosts/ignored_keywords
    downloaded_hosts_file_path=/etc/downloaded_hosts_file
    downloaded_updated_hosts_file_path=/etc/downloaded_updated_hosts_file

    if sudo cp "${own_hosts_file_path}" /etc/hosts; then
        substep "Copying ${own_hosts_file_path} to /etc/hosts succeeded"
    else
        error "Copying ${own_hosts_file_path} to /etc/hosts failed"
        exit 1
    fi

    if sudo wget --timeout=5 --tries=1 --quiet --output-document="${downloaded_hosts_file_path}" \
        https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts; then
        substep "hosts file downloaded successfully"

        if ack --invert-match "$(cat ${ignored_keywords_path})" "${downloaded_hosts_file_path}" | \
            sudo tee "${downloaded_updated_hosts_file_path}" > /dev/null; then
            substep "Ignored patterns successfully removed from downloaded hosts file"
        else
            error "Failed to remove ignored patterns from downloaded hosts file"
            exit 1
        fi

        if cat "${downloaded_updated_hosts_file_path}" | \
            sudo tee -a /etc/hosts > /dev/null; then
            success "/etc/hosts updated"
        else
            error "Failed to update /etc/hosts"
            exit 1
        fi

    else
        error "Failed to download hosts file"
    fi
}

function setup_macOS_defaults() {
    info "Updating macOS defaults"

    current_dir=$(pwd)
    cd ${DOTFILES_REPO}/macOS
    if bash defaults.sh; then
        cd $current_dir
        success "macOS defaults updated successfully"
    else
        cd $current_dir
        error "macOS defaults update failed"
        exit 1
    fi
}

function configure_vscode() {
    info "Configuring VSCode"
    current_dir=$(pwd)
    cd ${DOTFILES_REPO}/vscode
    if bash configure_vscode.sh; then
        cd $current_dir
        success "VSCode successfully configured"
    else
        cd $current_dir
        error "VSCode configuration failed"
        exit 1
    fi
}


# Utils

function coloredEcho() {
    local exp="$1";
    local color="$2";
    local arrow="$3";
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput bold;
    tput setaf "$color";
    echo "$arrow $exp";
    tput sgr0;
}

function info() {
    coloredEcho "$1" blue "========>"
}

function substep() {
    coloredEcho "$1" magenta "===="
}

function success() {
    coloredEcho "$1" green "========>"
}

function error() {
    coloredEcho "$1" red "========>"
}


main "$@"