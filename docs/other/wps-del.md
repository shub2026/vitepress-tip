# 清理安装WPS后的右键新建菜单 
>安装 WPS 后，右键「新建」菜单会出现 doc/docx、xls/xlsx、ppt/pptx 这种同类型，但不同格式的文件。
>为保持菜单清爽与格式统一，我决定保留新版开放格式的文件（docx、xlsx、pptx），移除旧版二进制格式的文件（doc、xls、ppt）。

## 一、手工清理方法
**对于doc文件**

打开注册表，定位到`HKEY_CLASSES_ROOT\.doc`，可以看到右侧的默认字符串值的数值数据（`WPS.Doc.6`)

那么我们可以手动删除注册表项`HKEY_CLASSES_ROOT\.doc\WPS.Doc.6\ShellNew`

**对于xls文件**

打开注册表，定位到`HKEY_CLASSES_ROOT\.xls`，可以看到右侧的默认字符串值的数值数据（`ET.Xls.6`）

那么我们可以手动删除注册表项`HKEY_CLASSES_ROOT\.xls\ET.Xls.6\ShellNew`

**对于ppt文件**

打开注册表，定位到`HKEY_CLASSES_ROOT\.ppt`，可以看到右侧的默认字符串值的数值数据（`WPP.PPT.6`）

那么我们可以手动删除注册表项`HKEY_CLASSES_ROOT\.ppt\WPP.PPT.6\ShellNew`

## 二、使用命令行
打开命令提示符，输入以下命令，即可删掉鼠标右键的“doc文档”
```sh
for /f "tokens=3* delims= " %i in ('reg query HKEY_CLASSES_ROOT\.doc /ve ^| findstr /i "REG_SZ"') do reg delete HKEY_CLASSES_ROOT\.doc\%i\ShellNew /f 2>nul
```
删掉鼠标右键的“xls工作表”
```sh
for /f "tokens=3* delims= " %i in ('reg query HKEY_CLASSES_ROOT\.xls /ve ^| findstr /i "REG_SZ"') do reg delete HKEY_CLASSES_ROOT\.xls\%i\ShellNew /f 2>nul
```
删掉鼠标右键的“ppt工作表”
```sh
for /f "tokens=3* delims= " %i in ('reg query HKEY_CLASSES_ROOT\.ppt /ve ^| findstr /i "REG_SZ"') do reg delete HKEY_CLASSES_ROOT\.ppt\%i\ShellNew /f 2>nul
```
## 三、使用批处理
将命令复制到文本文件，并将其后缀名重命名为`.cmd`或`.bat`（使用ANSI码保存）
```sh
@echo off
for %%e in (doc xls ppt) do call :rmShellNew %%e
pause
exit
 
:rmShellNew
for /f "tokens=3* delims= " %%i in ('reg query HKEY_CLASSES_ROOT\.%1 /ve ^| findstr /i "REG_SZ"') do reg delete HKEY_CLASSES_ROOT\.%1\%%i\ShellNew /f 2>nul
goto :eof
```

