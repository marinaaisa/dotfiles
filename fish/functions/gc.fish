function gc --wraps "git commit"
    git commit --quiet $argv
end
