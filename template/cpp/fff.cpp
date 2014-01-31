 EXE_BEGIN_TEMPLATE
        let classname = input("Please input class name : ")
        if classname =~ '^\s*$'
            let classname = "CClass"
        endif
        execute '%s/CClass/'.classname.'/g'
        if !filereadable(expand("%:t:r").'.cpp')
            execute "new ".expand("%:t:r").'.cpp'
            normal o
            call setline('.',classname."* ".classname."::m_ins = NULL;")
            normal o
            call setline('.',"auto_ptr<".classname."> ".classname."::m_auto_ptr;")
            normal o
            call setline('.',classname."::".classname."()")
            normal o
            call setline('.',"{")
            normal o
            call setline('.',"    m_auto_ptr = auto_ptr<".classname.">(this);")
            normal o
            call setline('.',"}")
            normal o
            call setline('.',classname."::~".classname."()")
            normal o
            call setline('.',"{")
            normal o
            call setline('.',"}")
            normal o
            call setline('.',classname."* ".classname."::Ins()")
            normal o
            call setline('.',"{")
            normal o
            call setline('.',"    if ( m_ins == NULL)")
            normal o
            call setline('.',"        m_ins = new ".classname."();")
            normal o
            call setline('.',"    return m_ins;")
            normal o
            call setline('.',"}")
            normal o
        endif
        EXE_END_TEMPLATE

