function gp --wraps "git push"
    git push --quiet $argv
end
