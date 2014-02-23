"------------------------------------------------------------------------------
" Description: 调整代码的格式以符合自己的编码风格 
"              当前支持c,python
" Author: xuxiaofeng 
" Version: 0.1
" TODO: 1、能忽略有些不需要格式化的部分,字符串、注释等 
"       2、支持不同的大括号缩进风格
"       3、对ESQL进行断行
"       4、对超过80列的进行断行
"       5、通过自定义方式支持其他语言
"------------------------------------------------------------------------------
if exists("g:loaded_formatcode") || &cp
    finish
endif
let g:loaded_formatcode = 1

let g:keywordList = ["if", "for", "while"]

function! s:FormatCode()
    " if,for,while,else关键字后调整为1个空格 
   	let index = 0
	while index < len(g:keywordList)
        let item = g:keywordList[index]
        echo item
        execute "\%s/" . item . "\\s*(/" . item . " (/g"
        echo "\%s/" . item . "\\s*(/" . item . " (/g"
        let index = index + 1
	endwhile
    " execute '%s/if\s*(/if (/g'
    " execute '%s/for\s*(/for (/g'
    " execute '%s/while\s*(/while (/g'

    execute '%s/else\s*{/else {/g'
    " 括号内侧去空格 
    execute '%s/(\s*/(/g'
    execute '%s/\s*)/)/g'
    execute '%s/\s*]/]/g'
    execute '%s/\s*[/[/g'
    " 逗号之前无空格，之后加一个空格
    execute '%s/\s*,\s*/, /g'
    " + - * / % < >前后加空格，FIXME 负数-12之类的负数的负号之后也会有空格
    execute '%s/\([+]\)\@<!\s*+\{-1}\([=+]\)\@!\s*/ + /g' 
    execute '%s/\([-]\)\@<!\s*-\{-1}\([=->]\)\@!\s*/ - /g' 
    execute '%s/\([/\*]\)\@<!\s*\*\{-1}\([=/\*]\)\@!\s*/ \* /g' 
    " FIXME 文件路径会受影响，因此先取消/作为除的格式修正
    " execute '%s/\([/\*]\)\@<!\s*\/\{-1}\([=/\*]\)\@!\s*/ \/ /g' 
    " FIXME  %在字符串中不应该加两边空格
    " execute '%s/\s*%\{-1}\([=]\)\@!\s*/ % /g'
    execute '%s/\([<]\)\@<!\s*<\{-1}\([>=<]\)\@!\s*/ < /g'
    execute '%s/\([<>-]\)\@<!\s*>\{-1}\([=>]\)\@!\s*/ > /g' 
    " 修正c中头文件中的<>
    execute '%s/\(^#include\)\@<=\s*<\{-1}\s*/ </g'
    execute '%s/\(^#include\)\@<!\s*>\{-1}\([=>]\)\@!\s*/>/g' 

    execute '%s/\s*++/++/g'
    execute '%s/\s*--/--/g'
    execute '%s/\s*\^\{-1}\([=]\)\@!\s*/ ^ /g' 
    execute '%s/\([|]\)\@<!\s*|\{-1}\([=|]\)\@!\s*/ | /g' 
    " 既是按位与，又是取地址符, 此处取后者 
    execute '%s/\([&]\)\@<!\s*&\{-1}\([=&]\)\@!\s*/ \&/g' 
    " =号前后加空格
    execute '%s/\([=!+-\*/%&^<>|]\)\@<!\s*=\{-1}\(=\)\@!\s*/ = /g'
    execute '%s/\s*==\s*/ == /g'
    execute '%s/\s*+=\s*/ += /g'
    execute '%s/\s*-=\s*/ -= /g'
    execute '%s/\([<]\)\@<!\s*<=\s*/ <= /g'
    execute '%s/\([>]\)\@<!\s*>=\s*/ >= /g'
    execute '%s/\s*!=\s*/ != /g'
    execute '%s/\s*&=\s*/ \&= /g'
    execute '%s/\s*\/=\s*/ \/= /g'
    execute '%s/\s*%=\s*/ %= /g'
    execute '%s/\s*\^=\s*/ \^= /g'
    execute '%s/\s*\*=\s*/ \*= /g'
    execute '%s/\s*|=\s*/ |= /g'
    execute '%s/\s*||\s*/ || /g'
    execute '%s/\s*&&\s*/ \&\& /g'
    execute '%s/\s*>>=\s*/ >>= /g'
    execute '%s/\s*<<=\s*/ <<= /g'
    " 处理三目运算符?:
    execute '%s/\s*?\s*/ ? /g'
    " python中的分隔符不加空格 FIXME:ESQL中将 :a 视为变量
    " execute '%s/\s*:\(\S\)\@=\s*/ : /g'
    " 处理->
    execute '%s/\s*->\s*/->/g'
    execute '%s/\s*\.\s*/./g'
    " 支持python的乘方运算符**
    execute '%s/\s*\([/\*]\)\@<!\*\*\([/\*]\)\@!\s*/ \*\* /g'

    call s:ChangeBrace()
    " 调整缩进
    normal! gg=G
endfunction

function! s:ChangeBrace()
    normal G$
    let flags = "w"
    echo "^\s*{"
    while search("^\\s*{", flags) > 0
        if line(".") != 1
            normal! k
            " TODO:判断是否为无效行，如空行，注释行等
            " c的换行符\
            execute 's/\\\s*$//g'
            " FIXME: 连接上一行后,{置于括号之后
            normal! J
        endif
        let flags = "W"
    endwhile
    " update
endfunction
nmap <leader>test :call ChangeBrace()<CR>

command! FormatCode call s:FormatCode()
if !hasmapto('<Plug>FormatCode')
    map <unique><leader>fmt <Plug>FormatCode
endif
nmap <unique><script><Plug>FormatCode :FormatCode<CR>
