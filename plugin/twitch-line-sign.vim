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

function! TwitchLineSignPlaceSign(line, nick, suggestion) abort
  let file = @%
  call s:addSignToDict(file, a:line, a:nick, a:suggestion, s:currentIndex)
  exe "sign place " . s:currentIndex . " line=" . a:line . " name="  . s:signGroupName
  let s:currentIndex = s:currentIndex + 1
  echo ""
endfunction

function! TwitchLineSignCheckLine() abort
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

function! TwitchLineSignClear(line1, line2) abort
  let file = @%
  let line = line(".")

  for line in range(a:line1, a:line2)
    if has_key(s:currentSigns, file) && has_key(s:currentSigns[file], line)
      let fileSigns = get(s:currentSigns, file)
      let fileLineSigns = get(fileSigns, line)
      for lineSign in fileLineSigns
        exe "sign unplace " . lineSign.index
      endfor
      call remove(s:currentSigns[file], line)
    endif
  endfor
  return ''
endfunction

function! TwitchLineSignClearAllSigns() abort
  return TwitchLineSignClearSigns(1, line("$"))
endfunction

function! TwitchLineSignClearSign() abort
  return TwitchLineSignClearSigns(line("."), line("."))
endfunction

function! s:Callback(channel, msg) abort
  call TwitchLineSignPlaceSign(a:msg.line, a:msg.nick, a:msg.suggestion)
endfunction

function! TwitchLineSignChatConnect(...) abort
  let host_port = a:0 ? a:1 : 'localhost:6969'
  let ch = ch_open(host_port, {
        \ 'mode': 'json',
        \ 'callback': function('s:Callback'),
        \ })
  if ch_status(ch) ==# 'open'
    let g:twitch_chat_connection = ch
    echo 'Connected'
    return ''
  else
    return 'echoerr ' . string('Failed to connect')
  endif
endfunction

function! TwitchLineSignChatDisconnect() abort
  if exists('g:twitch_chat_connection')
    call ch_close(g:twitch_chat_connection)
    unlet g:twitch_chat_connection
    echo 'Disconnected'
  else
    echo 'No connection'
  endif
  return ''
endfunction

augroup twitch
  autocmd!
  autocmd CursorMoved * call TwitchLineSignCheckLine() 
augroup END

command! -bar -nargs=? TwitchLineSignChatConnect    execute TwitchLineSignChatConnect(<f-args>)
command! -bar          TwitchLineSignChatDisconnect execute TwitchLineSignChatDisconnect()
command! -bar -range   TwitchLineSignClear          execute TwitchLineSignClear(<line1>, <line2>)
