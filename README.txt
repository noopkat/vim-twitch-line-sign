Twitch Line Sign

Kinda just does what it says on the tin - it provides some helpers to annotate vim signs with Twitch related metadata so that viewers can call attention to specific lines of code using a chat command.

After this sign is placed, information about the Twitch nick and their corresponding suggestion/question will display when the cursor is on the signed line. 

==============================================================================
Global Functions

:call TwitchLineSignPlaceSign(line, nick, suggestion)
This function is the main go-to for placing a "twitch" named sign with attached metadata (the twitch nick and their suggestion).  Call it whenever a chat message comes in with the !line command to place the sign and annotate it. Right now it just uses the current active file as the location for placement.

:call TwitchLineSignCheckLine()
This function is set to `autocmd CursorMoved` and will output the Twitch nick and their suggestion if the cursor is on a line with a twitch sign placed.

:call TwitchLineSignClearSign()
This function clears all twitch named signs on the current line the cursor is placed at.

:call TwitchLineSignClearAllSigns()
This function clears all twitch named signs in all currently open buffers.

==============================================================================
About

By @noopkat
I have no idea what I'm doing but this little script helped me so I put it on GitHub in case someone else can use it.

http://github.com/noopkat/twitch-sign-line

==============================================================================
License

Released under the MIT license.

------------------------------------------------------------------------------
