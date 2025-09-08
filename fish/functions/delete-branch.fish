function branch-delete
  git branch -D $argv
  git push origin --delete $argv
end
