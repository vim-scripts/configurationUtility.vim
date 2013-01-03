" Documentation {{{1
" Name: configurationUtility.vim
" Version: 1.0
" Description: Save and load configuration files in a dictionary format containing sections and items. I wanted to have a way to save and load configuration data with items and sections like .ini files on Windows, and I found that it could be possible using dictionaries.
" The functions in this plugin are used to create and load a file like this which contains a large dictionary that contains items and one level of subitems called sections.

" Here are the available functions:
" g:CfgLoadFromFile(file) 
" g:CfgSaveToFile(cfg, file) 
" g:CfgGetItem(dict, itemKey) 
" g:CfgGetItemKey(dict, itemValue) 
" g:CfgRemoveItem(dict, itemKey) 
" g:CfgSetItem(dict, itemKey, itemValue) 
" g:CfgGetSection(dict, sectionKey) 
" g:CfgSetSection(dict, sectionKey, sectionvalue) 
" g:CfgSectionRemove(dict, sectionKey) 
" g:CfgSectionGetItem(dict, sectionKey, itemKey) 
" g:CfgSectionGetItemKey(dict, itemValue) 
" g:CfgSectionRemoveItem(dict, sectionKey, itemKey) 
" g:CfgSectionSetItem(dict, sectionKey, itemKey, itemValue) 
" g:CfgSectionExists(dict, sectionKey) 

" The sections themselves contains items. So at the first level there are items and sections, and in the sections there are items only.
" For example here items would be 'history', 'favorites', 'lastPath'. The sections would be for example 'selectedFiles', 'marks', and items in the sections in this example would be 'B', 'C', etc...  
" let g:Cfg = {'selectedFiles': {}
" \, 'marks': {'A': 'C:\Usb\i_green\apps'
" \, 'B': 'C:\Users\User\Desktop'
" \, 'C': 'C:\'
" \, 'D': 'C:\Usb\i_green\data'
" \, 'F': 'C:/Windows/Microsoft.NET/Framework64/v4.0.30319'
" \, 'G': 'G:\'
" \, 'H': 'C:\Users'
" \, '2': 'C:/Usb/iomega/Video'
" \, 'M': 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs'
" \, 'P': 'C:\vim\vim73\plugin'
" \, 'S': 'C:\Users\User\Documents\Shortcuts'
" \, 'T': 'C:\Temp'
" \, 'U': 'C:\Usb'
" \, 'V': 'C:\vim\vim73'
" \, 'W': 'C:/Usb/z_white'
" \, '3': 'C:/Temp/a1'
" \, 'a': 'C:\Usb\z_white\Apps\Portable'
" \, 'b': 'C:\Users\User\Desktop'
" \, 'c': 'C:\Usb\z_white\Apps\Portable\CmdUtils'
" \, 'd': 'C:\Users\User\Documents'
" \, 'e': 'C:/Users/User/Documents/emails'
" \, 'f': 'C:/Windows/Microsoft.NET/Framework64/v4.0.30319'
" \, 'g': 'G:\'
" \, 'h': 'C:\Users\User'
" \, 'i': 'C:\Usb\i_green'
" \, 'm': 'C:/Users/User/AppData/Roaming/Microsoft/Windows/Start Menu/Programs'
" \, 'n': 'C:/Usb/i_green/data/Notes'
" \, 'p': 'C:\Usb\i_green\data\Projects'
" \, 'r': 'C:\repository'
" \, 's': 'C:\Users\User\Documents\Shortcuts'
" \, 't': 'C:\Temp'
" \, 'u': 'C:\Usb'
" \, 'v': 'C:\vim\vim73'
" \, 'w': 'C:\Windows'
" \, '8': 'C:/HP'
" \, '9': 'C:/HP/support'
" \, 'z': 'C:/Windows/Logs'}
" \, 'history': '[C:/Usb/z_white/Data/] [C:/Usb/z_white/Data/] [C:/Temp/allo] [C:/Temp/allo/a5/zzz/wwwwwwww]'
" \, 'favorites': '[C:/cygwin] [C:/cygwin/usr/share/vim/vim73]'
" \, 'cursorPos': {'C:/Temp/a1': '..'
" \, 'C:/Temp/a2': 'bclear.vim'
" \, 'C:/Temp/a3': '.'
" \, 'C:/Temp/a5': '..'
" \, 'C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Security and Protection': '..'
" \, 'C:/Usb/iomega/Documents/Emails': 'John_bak.dbx'
" \, 'C:/Usb/iomega/Documents/Orthodox (faire menage)/Early Church Fathers v.2.0': 'ecf02.hlp'}
" \, 'lastPath': 'C:/Usb/'}
"
" Author: Alexandre Viau (alexandreviau@gmail.com)
" Installation: Copy the plugin to the vim plugin directory.
" Functions: Persistance {{{1

" g:CfgLoadFromFile(file) {{{2
" Load a configuration from file (.vim file) 
fu! g:CfgLoadFromFile(file)
    if filereadable(a:file)
        try
            exe "source " . a:file
            let cfg = deepcopy(g:Cfg)
        catch
            let cfg = {}
        finally
            unlet! g:Cfg " Free memory
            return cfg
        endtry
    else
        return {}
    endif
endfu

" g:CfgSaveToFile(cfg, file) {{{2
" Save a dictionnary to file (.vim file)
fu! g:CfgSaveToFile(cfg, file)
    let file = substitute(a:file, '/', '\', 'g')
    let file = substitute(file, '\', '\\', 'g')
    " Echo the configuration dictionary to file {{{3
    exe "redir! > " . file
    silent echo a:cfg
    redir END
    " Read the file back to a variable {{{3
    let cfgMono = readfile(file)
    " Make the configuration file multiline using split {{{3
    let cfgMulti = split(cfgMono[1], ',')
    " Add "\" to lines that where split
    for i in range(0, len(cfgMulti) - 1)
        if strpart(cfgMulti[i], 0, 2) == " '"
            let cfgMulti[i] = '\,' . cfgMulti[i]
        endif
    endfor
    " Add the global g:Cfg variable name {{{3
    let cfgMulti[0] =  'let g:Cfg = ' . cfgMulti[0]
    " Add comment to the config file {{{3
    cal writefile(cfgMulti, file, 'b')
endfu

" Functions: Item {{{1

" g:CfgGetItem(dict, itemKey) {{{2
" Get an item value
fu! g:CfgGetItem(dict, itemKey)
    if has_key(a:dict, a:itemKey)
        return a:dict[a:itemKey]
    else
        return ''
    endif
endfu

" g:CfgGetItemKey(dict, itemValue) {{{2
" Get an item key from a item value
fu! g:CfgGetItemKey(dict, itemValue)
    for [key, value] in items(a:dict)
        if value == a:itemValue
            return key
        endif
    endfor
    return ''
endfu

" g:CfgRemoveItem(dict, itemKey) {{{2
" Remove an item from a dictionnary
fu! g:CfgRemoveItem(dict, itemKey)
    cal remove(a:dict, a:itemKey)
endfu

" g:CfgSetItem(dict, itemKey, itemValue) {{{2
" Set a value to a item
fu! g:CfgSetItem(dict, itemKey, itemValue)
    let itemValue = a:itemValue
    " Double ' if any because values are delimited by ''
    if stridx(a:itemValue, "'") != -1
       let itemValue = substitute(itemValue, "'", "''", "g") 
    endif
    cal extend(a:dict, {a:itemKey : a:itemValue}, 'force')"
endfu

" Functions: Section {{{1

" g:CfgGetSection(dict, sectionKey) {{{2
" Get a entire section
fu! g:CfgGetSection(dict, sectionKey)
    if has_key(a:dict, a:sectionKey)
        return a:dict[a:sectionKey]
    else
        return {}
    endif
endfu

" g:CfgSetSection(dict, sectionKey, sectionvalue) {{{2
" Set a section to a dictionnary passed in the sectionValue parameter
fu! g:CfgSetSection(dict, sectionKey, sectionValue)
    " Will be erased if there is already something in that dictionnary
    cal extend(a:dict, {a:sectionKey : a:sectionValue}, 'force')"
endfu

" g:CfgSectionRemove(dict, sectionKey) {{{2
" Remove a entire section
fu! g:CfgSectionRemove(dict, sectionKey)
    if has_key(a:dict, a:sectionKey)
        cal remove(a:dict, a:sectionKey)
    endif
endfu

" g:CfgSectionGetItem(dict, sectionKey, itemKey) {{{2
" Get a value from a section
fu! g:CfgSectionGetItem(dict, sectionKey, itemKey)
    if !has_key(a:dict, a:sectionKey)
        return ''
    endif
    if !has_key(a:dict[a:sectionKey], a:itemKey)
        return ''
    endif
    let section = a:dict[a:sectionKey] 
    return section[a:itemKey]
endfu

" g:CfgSectionGetItemKey(dict, itemValue) {{{2
" Get an item key from a item value
fu! g:CfgSectionGetItemKey(dict, sectionKey, itemValue)
    if !has_key(a:dict, a:sectionKey)
        return ''
    endif
    for [key, value] in items(a:dict[a:sectionKey])
        if value == a:itemValue
            return key
        endif
    endfor
    return ''
endfu

" g:CfgSectionRemoveItem(dict, sectionKey, itemKey) {{{2
" Remove an item from a section
fu! g:CfgSectionRemoveItem(dict, sectionKey, itemKey)
    if has_key(a:dict, a:sectionKey)
        cal remove(a:dict[a:sectionKey], a:itemKey)
    endif
endfu

" g:CfgSectionSetItem(dict, sectionKey, itemKey, itemValue) {{{2
" Set a value to a section
fu! g:CfgSectionSetItem(dict, sectionKey, itemKey, itemValue)
    " Add the section if it dosen't exist
    if !has_key(a:dict, a:sectionKey)
        cal extend(a:dict, {a:sectionKey : {}}, 'force')"
    endif
    " Get the section
    let section = a:dict[a:sectionKey]
    " Set the section item
    cal extend(section, {a:itemKey : a:itemValue}, 'force')"
    " Set the section
    cal extend(a:dict, {a:sectionKey : section}, 'force')"
endfu

" g:CfgSectionExists(dict, sectionKey) {{{2
fu! g:CfgSectionExists(dict, sectionKey)
    if has_key(a:dict, a:sectionKey)
        return 1
    else
        return 0
    endif
endfu
