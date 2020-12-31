function update-all
    sudo softwareupdate --install --all
    brew update
    brew upgrade
    mas upgrade
    brew upgrade --cask
    brew outdated --cask --greedy --verbose | ack --invert-match latest | awk '{print $1;}' | xargs brew upgrade --cask
    brew cleanup
    brew doctor
end
