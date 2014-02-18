" 周报的语法高亮文件

syn keyword Zbkeyword1 startdate reportdate enddate
syn keyword Zbkeyword2 Worklist Problem Plan
syn match Zbdigital /\d\+/
syn match Zbdate /20\d\{6\}/
syn match Date /\d\{4}年\d\{1,2}月\d\{1,2}日/
syn match Date /\d\{1,2}月/
syn match Date /\d\{1,2}月\d\{1,2}日/
syn match Time /\d\{1,2}:\d\{1,2}/
syn match Time /\d\{1,2}:\d\{1,2}:\d\{1,2}/
syn match Xuhao /^\d\+/
syn match shuxian /|/
syn match DCM /DCM:\w\+\d\+/

hi link Zbkeyword1 Statement
hi link Zbkeyword2 Pmenu
hi link Xuhao Todo
hi shuxian gui=underline guifg=green 
hi link Zbdigital Number 
hi link Zbdate Special
hi link Date Number
hi link Time Number 
hi link DCM SpecialChar
