  function sync-brew
    set --local TAP  ~/dotfiles/brew/Brewfile_tap
    set --local BREW ~/dotfiles/brew/Brewfile_brew
    set --local CASK ~/dotfiles/brew/Brewfile_cask
    set --local MAS  ~/dotfiles/brew/Brewfile_mas
    set --local BREWFILE ~/dotfiles/brew/Brewfile

    cat $TAP $BREW $CASK $MAS > $BREWFILE
    brew bundle cleanup --file=$BREWFILE --force
end