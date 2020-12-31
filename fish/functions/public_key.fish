function public_key
    set --local PRIVATE_KEY_PATH ~/.ssh/id_rsa
    set --local PUBLIC_KEY_PATH  ~/.ssh/id_rsa.pub

    if test ! -e $PUBLIC_KEY_PATH
        ssh-keygen -f $PRIVATE_KEY_PATH
    end

    cat $PUBLIC_KEY_PATH | tr -d '\n' | pbcopy
end
