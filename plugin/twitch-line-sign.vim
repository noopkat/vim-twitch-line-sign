if exists('g:loaded_twitchlinesign')
  finish
endif
let g:loaded_twitchlinesign = 1

let s:currentSigns = {}
let s:currentIndex = 1
let s:signGroupName = "twitch"
let s:signGroupText="👀"
let s:signGroupHighlight="Error"

exe "sign define " . s:signGroupName . " text=" . s:signGroupText . " texthl=" . s:signGroupHighlight

function s:addSignToDict(file, line, nick, suggestion, currentIndex)
  let entry = {'nick': a:nick, 'suggestion': a:suggestion, 'index': a:currentIndex}

  if !has_key(s:currentSigns, a:file)
    let s:currentSigns[a:file] = {}
  endif

  if !has_key(s:currentSigns[a:file], a:line)
    let s:currentSigns[a:file][a:line] = []
  endif
  
  call insert(s:currentSigns[a:file][a:line], entry)
endfunction

function! TwitchLineSignPlaceSign(line, nick, suggestion)
  let file = @%
  call s:addSignToDict(file, a:line, a:nick, a:suggestion, s:currentIndex)
  exe "sign place " . s:currentIndex . " line=" . a:line . " name="  . s:signGroupName
  let s:currentIndex = s:currentIndex + 1
  echo ""
endfunction

function! TwitchLineSignCheckLine()
  let file = @%
  let line = line(".")
  let echoString = ""

  if has_key(s:currentSigns, file) && has_key(s:currentSigns[file], line)
    let fileSigns = get(s:currentSigns, file)
    let fileLineSigns = get(fileSigns, line)

    for lineSign in fileLineSigns 
      let echoString = echoString . lineSign.nick . " - " . lineSign.suggestion . "; "
    endfor
  endif

  echo echoString
endfunction

function! TwitchLineSignClearAllSigns()
  for file in keys(s:currentSigns)
    for line in keys(s:currentSigns[file])
      for lineSign in s:currentSigns[file][line] 
        exe "sign unplace " . lineSign.index
      endfor
    endfor
  endfor
  let s:currentSigns = {}
endfunction

function! TwitchLineSignClearSign()
  let file = @%
  let line = line(".")

  if has_key(s:currentSigns, file) && has_key(s:currentSigns[file], line)
    let fileSigns = get(s:currentSigns, file)
    let fileLineSigns = get(fileSigns, line)
    for lineSign in fileLineSigns 
      exe "sign unplace " . lineSign.index
    endfor
    let s:currentSigns[file][line] = []
  endif
endfunction

augroup twitch
  autocmd!
  autocmd CursorMoved * call TwitchLineSignCheckLine() 
augroup END

