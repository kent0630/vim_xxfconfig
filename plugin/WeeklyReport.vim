"------------------------------------------------------------------------------
" Description: 用于写周报,实现文本格式书写周报生成转换成word格式
" Author: xuxiaofeng 
" Version: 0.1
" TODO:   1、处理异常
        " 2、保存周报文本数据
        " 3、处理报表文件的高亮显示
        " 4、异常和成功的提示
        " 5、发送邮件功能
" FIXME " 1、如何导入自定义python文件
" 该插件需要python支持
if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif
" 全局变量设置
if exists("g:loaded_weeklyreport") || &cp
    finish
endif
let g:loaded_weeklyreport = 1
"-------------------------------------------------------------------------------

" 周报模版路径
"-------------------------------------------------------------------------------
if !exists("g:weeklyreport_template_file")
    let g:weeklyreport_template_file='f:/baiduyun/python/wr.doc'
endif

" 周报输出路径(DOC)
"-------------------------------------------------------------------------------
if !exists("g:weeklyreport_output_path")
    let g:weeklyreport_output_path='f:/baiduyun/python/'
endif
" 周报文本保存路径
"-------------------------------------------------------------------------------
if !exists("g:weeklyreport_save_path")
    let g:weeklyreport_save_path='f:/baiduyun/python/zb/'
endif

" 周报名称
"-------------------------------------------------------------------------------
if !exists("g:weeklyreport_doc_name")
    let g:weeklyreport_doc_name='$year年第$week周周报(徐小峰)'
endif

function! s:MakeWeeklyReport()
" 调用python语言
python << PYTHONEOF
# encoding=utf-8
import vim
import sys
import win32com.client
import os
import shutil
import calendar
from datetime import datetime
# from win32word import easyword
class easyword:
    def __init__(self, filename = None, visiable = 1):
        self.wordapp = win32com.client.gencache.EnsureDispatch("Word.Application")
        self.wordapp.Visible = visiable
        if filename:
            self.filename = os.path.abspath(filename)
            self.wordapp.Documents.Open(self.filename)

    def Save(self, file_):
        if file_:
            path = os.path.abspath(file_)
            self.wordapp.ActiveDocument.SaveAs(path)
        else:
            self.wordapp.ActiveDocument.Save()

    def Find(self, findstr):
        self.wordapp.Selection.Find.Wrap = 1
        self.wordapp.Selection.Find.Execute(findstr)

    def Replace(self, src, dst):
        wdFindContinue = 1
        wdReplaceAll = 2
        find_str = src
        replace_str = dst
        self.wordapp.Selection.Find.Execute(find_str, False, False, False,\
            False, False, True, wdFindContinue, False, replace_str, wdReplaceAll)

    def close(self):
        self.wordapp.ActiveWindow.Close()

    def MoveRight(self, step = 1):
        self.wordapp.Selection.MoveRight(1,step)

    def MoveLeft(self, step = 1):
        self.wordapp.Selection.MoveLeft(1,step)

    def MoveUp(self):
        self.wordapp.Selection.MoveUp()

    def MoveDown(self):
        self.wordapp.Selection.MoveDown()

    def HomeKey(self):
        self.wordapp.Selection.HomeKey()

    def EndKey(self):
        self.wordapp.Selection.EndKey()

    def EscapeKey(self):
        self.wordapp.Selection.EscapeKey()

    def Delete(self):
        self.wordapp.Selection.Delete ()

    def SelectCell(self):
        self.wordapp.Selection.SelectCell()

    def Copy(self):
        self.wordapp.Selection.Copy()

    def Paste(self):
        self.wordapp.Selection.Paste()

    def TypeText(self,text):
        self.wordapp.Selection.TypeText(text)

    def CellRight(self):
        self.EndKey()
        self.MoveRight()

    def CellLeft(self):
        self.HomeKey()
        self.MoveLeft()

    def DelThenFillCell(self,text):
        self.SelectCell()
        self.Delete()
        self.TypeText(text)

    def InsertRowBelow(self):
        self.wordapp.Selection.InsertRowsBelow()

    def SetTableValue(self, tableid, row, col, value):
        self.wordapp.ActiveDocument.Tables(tableid).Cell(row,col).Range.Text = value

    def GetTableValue(self, tableid, row, col, value):
        return self.wordapp.ActiveDocument.Tables(tableid).Cell(row,col).Range.Text

    def GetTableRange(self, tableid, row1, col1, row2, col2):
        cell1 = self.wordapp.ActiveDocument.Tables(tableid).Cell(row1,col1)
        cell2 = self.wordapp.ActiveDocument.Tables(tableid).Cell(row2,col2)
        range = self.wordapp.ActiveDocument.Range(cell1.Range.Start, cell2.Range.Start)
        return range

    def GetCellByCotent(self, text):
        pass
        #return Range

    def Close(self):
        self.wordapp.ActiveWindow.Close()
        self.wordapp.Quit()

def getWeekNum(date):
    '''获得给定日期是这一年的第几周。
    每周以周一为一周的开始，但1月1日不是周一时,算作上一年的最后一周,返回0'''
    year = date.year
    wdd = calendar.weekday(year, 1, 1)
    days = (date - datetime(year, 1, 1)).days
    nweek = 0
    if wdd:
        nweek=(days + wdd) / 7
    else:
        nweek=days/7+1
    return nweek 

def getValue(line, key=""):
    keyValue = line.split(":") 
    return keyValue[1]

def getMonth(date_string):
    i = 4
    if date_string[4] == '0':
        i+=1
    return date_string[i:6]

def getDay(date_string):
    i = 6
    if date_string[6] == '0':
        i+=1
    return date_string[i:8]

def getYear(date_string):
    return date_string[0:4]

def writeContent(line, flag):
    global TABLELINE
    global ITEMCOUNT
    if line == "":
        return
    if flag == 0:
        return  
    content = line.split("|")
    rg = wd.GetTableRange(1, TABLELINE+2*(flag-1), 1, TABLELINE+2*(flag-1), 1)
    rg.Select()
    if (ITEMCOUNT != 1):
        wd.InsertRowBelow()
    TABLELINE += 1
    ITEMCOUNT += 1
    for i in range(len(content)):
        wd.SetTableValue(1, TABLELINE + 2*(flag-1), i+1,\
                content[i].decode("utf-8").encode("cp936"))

def processLine(l):
    global FLAG
    global ITEMCOUNT
    global REPORT_YEAR
    global REPORT_WEEK
    if  l.startswith('reportdate'):
        r_year = getYear(getValue(l))
        r_month = getMonth(getValue(l))
        r_day = getDay(getValue(l))
        wd.Replace("$ryear", r_year)
        wd.Replace("$rmonth", r_month)    
        wd.Replace("$rday", r_day)
        REPORT_YEAR = r_year
        week = getWeekNum(datetime(int(r_year), int(r_month), int(r_day)))
        REPORT_WEEK = str(week)
        wd.Replace("$week",week)
    elif  l.startswith('startdate'):
        s_year = getYear(getValue(l))
        s_month = getMonth(getValue(l))
        s_day = getDay(getValue(l))
        wd.Replace("$smonth", s_month)    
        wd.Replace("$sday", s_day)
    elif  l.startswith('enddate'):
        e_year = getYear(getValue(l))
        e_month = getMonth(getValue(l))
        e_day = getDay(getValue(l))
        wd.Replace("$emonth", e_month)    
        wd.Replace("$eday", e_day)
    elif l.startswith('Worklist:'):
        FLAG = 1 
        ITEMCOUNT = 1
    elif l.startswith('Problem:'):
        FLAG = 2 
        ITEMCOUNT  = 1
    elif l.startswith('Plan:'):
        FLAG = 3 
        ITEMCOUNT = 1
    else:
        writeContent(l, FLAG)

vim.command("echohl MoreMsg")
vim.command("echo '开始生成周报...请稍后...'")
vim.command("echohl None")

ITEMCOUNT = 0
WORD_TEMPLATE_FILE = (vim.vars)["weeklyreport_template_file"]
OUTPUT_PATH = (vim.vars)["weeklyreport_output_path"]
DOC_NAME = (vim.vars)["weeklyreport_doc_name"]

# 将模版文件复制到输出路径 
OUTPUT_FILE = OUTPUT_PATH + DOC_NAME + ".doc"
OUTPUT_FILE = unicode(OUTPUT_FILE, "utf-8")
# if os.path.isfile(NEW_FILE_NAME):
    # os.remove(NEW_FILE_NAME)
shutil.copyfile(WORD_TEMPLATE_FILE, OUTPUT_FILE) 

# 处理报表文件，一旦失败删除该文件
wd = easyword(OUTPUT_FILE, 0)
FLAG = 0
TABLELINE = 4
REPORT_YEAR = 0
REPORT_WEEK = 0
ITEMCOUNT = 0

current_buffer = vim.current.buffer
for i in range(0, len(current_buffer)):
    processLine(current_buffer[i])

wd.Save("")
wd.Close()

NEW_FILE_NAME = OUTPUT_FILE.replace('$year', REPORT_YEAR)
NEW_FILE_NAME = NEW_FILE_NAME.replace('$week', REPORT_WEEK)

if os.path.isfile(NEW_FILE_NAME):
    os.remove(NEW_FILE_NAME)
os.rename(OUTPUT_FILE, NEW_FILE_NAME)
print NEW_FILE_NAME + u"生成成功"

PYTHONEOF
endfunction

" 定义命令
command! WeeklyReport  call s:MakeWeeklyReport()

" 定义默认的映射 
if !hasmapto('<Plug>WeeklyReport')
   map <unique><leader>wwr <Plug>WeeklyReport
endif
nnoremap <unique><script><Plug>WeeklyReport :WeeklyReport<CR>
