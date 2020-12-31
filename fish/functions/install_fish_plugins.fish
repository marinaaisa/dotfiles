function install_fish_plugins
    set --local FISH_PLUGINS (cat $DOTFILES_REPO/fish/plugins)

    http --body --follow https://git.io/fisher | source
    fisher install $FISH_PLUGINS
end
