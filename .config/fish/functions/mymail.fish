function mymail
	mbsync -a
    notmuch new 2> /dev/null
    neomutt
	and mbsync -a
end
