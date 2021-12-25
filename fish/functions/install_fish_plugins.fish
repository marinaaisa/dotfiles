function install_fish_plugins
    set --local FISH_PLUGINS (cat fish/plugins)

    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

    omf install chain
    omf theme chain

    fisher install $FISH_PLUGINS

    nvm install lts
    set --universal nvm_default_version lts
end
