'CLEAR KEYS clears the keyboard buffer.
sub ClearKeys
    do:sleep 1:loop while inkey <> ""
end sub