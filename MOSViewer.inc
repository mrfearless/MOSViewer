;=====================================================================================
; Directory Opus Viewer Plugin for Masm  - fearless
; https://github.com/mrfearless/MOSViewer
;
; MOSViewer.inc
;
;-------------------------------------------------------------------------------------
include windows.inc
include CommCtrl.inc
include shellapi.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib shell32.lib

include IEMOS.inc
includelib IEMOS.lib

.CONST
CRLF                TEXTEQU <13,10,0> ; carriage return and linefeed

ICO_MOS_LARGE       EQU 100
ICO_MOS_SMALL       EQU 101

.DATA
szMOSViewer         DB "MOSViewer",0
szMOSViewerAbout    DB 13,10         
                    DB "MOSViewer Directory Opus Viewer Plugin by fearless 2019 - github.com/mrfearless",13,10
                    DB 13,10
                    DB "MOSViewer Features & Usage:",13,10
                    DB " - ",13,10  
                    DB 13,10,0
szMOSURL            DB "https://www.github.com/mrfearless",0
szMOSExt            DB ".mos;.mosc",0
szMOSFile           DB "MOS",0
szMOSViewerInfo     DB "MOS Viewer Plugin - for MOS V1.0 formats",0

szMOSFormat         DB "%ld x %ld x %ld MOS V1.0 Image",0
szMOSCFormat        DB "%ld x %ld x %ld Compressed MOS V1.0 Image",0
;szMOSFormat         DB "MOS Image",0

MOSViewerGUID       GUID <01A1BE7A0h,0AA99h,0C33Ch,<09Dh,0EDh,02Dh,0B3h,051h,05h,0A7h,0CAh>>

MOSFileInfoBuffer   DB 256 DUP (0)

hICO_MOS_LARGE      DQ 0
hICO_MOS_SMALL      DQ 0

.DATA?
hInstance           HINSTANCE ?

