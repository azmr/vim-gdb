" takes line numbers as args to set as breakpoints; if none given, sets
" breakpoint on current line
function! QuickGDB(...)
	" TODO: new functions for watchlists/other GDB functions
	" TODO: set breakpoints in file and store list of them (for session?)
	" TODO: make vim interactable while GDB open - pipe into scratch buffer?
	let l:args=a:000
	let l:owd=getcwd()
	let l:filename=expand('%:p')
	let l:gdbargs=[]

	" include breakpoint arguments
	" no args --> break on current line
	if a:0 ==# 0
		let l:currentline=line('.')
		call add(l:gdbargs, '-ex "b ' . l:filename . ':' . l:currentline . '"')
	else
		for l:arg in l:args
			" number --> line numbers in current file
			" TODO: explicitly deal with numbers > line numbers of file?
			if type(l:arg) ==# type(0)
				call add(l:gdbargs, '-ex "b ' . l:filename . ':' . l:arg . '"')

			" string --> file name and line number
			elseif type(l:arg) ==# type('')
				let l:bufmatchpattern='b\(uf\(fer\)\?\)\?\s*\([^:]*\)\(:\(\d\+\)\)\?'
				" if given absolute address, use that
				if l:arg[0] ==# '/' || l:arg[1] ==# ':'
					call add(l:gdbargs, '-ex "b ' . l:arg . '"')

				" or use buffer if given that
				elseif l:arg =~ l:bufmatchpattern
					let l:buf=expand('%')
					let l:bufalt=expand('#')
					let l:buftest=matchlist(l:arg, l:bufmatchpattern)
					echo l:buftest

					" echom l:buftest[0]
					let l:bufname=l:buftest[3]
					" echom l:bufname
					let l:bufline=l:buftest[5]
					" echom l:bufline
					if l:bufline ==# '' && type(l:bufline) ==# type('')
						let l:bufline=input('Enter a line number for buffer ' .  l:bufname . " or leave blank for current line in that buffer\r> ")
					endif

					execute 'b ' . l:bufname
					call add(l:gdbargs, '-ex "b ' . expand('%:p') . ':' . l:bufline . '"')

					" keeps original % and #
					execute 'b ' . l:bufalt
					execute 'b ' . l:buf


				" otherwise consider address relative to l:owd
				else
					call add(l:gdbargs, '-ex "b ' . l:owd . '/' . l:arg . '"')
				endif

			else
				echom 'QuickGDB: Inappropriate argument; must be a number or a string'
				return
			endif
		endfor
	endif

	" find executable based on filetype
	" TODO: add more filetypes
	if &filetype ==? 'rust'
		" assumes working file in src sub+directory
		" start in directory of current file and 'cd ..' until in src parent dir
		cd %:p:h
		while fnamemodify(getcwd(), ':p:h:t') !=# 'src'
			:cd ..
		endwhile
		:cd ..

		let l:cratepath=fnamemodify(getcwd(), ':p')
		let l:cratename=fnamemodify(l:cratepath, ':h:t')
		" assumes Windows TODO: make platform independent
		let l:debugtarget=l:cratepath . 'target/debug/' . l:cratename . '.exe'
	else
		echom 'QuickGDB: not sure what to do with the filetype ' . &filetype
		return
	endif

	execute 'cd '. l:owd

	execute 'silent !gdb -q ' . l:debugtarget . ' ' . join(l:gdbargs)
endfunction
