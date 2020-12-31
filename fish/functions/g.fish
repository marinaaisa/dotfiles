function g --wraps "git status"
    clear; and git status --short --branch $argv
end
