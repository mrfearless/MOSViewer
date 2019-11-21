;=====================================================================================
; Directory Opus Viewer Plugin for Masm - fearless 2019 - www.github.com/mrfearless
;
; MOSViewer.asm
;
;-------------------------------------------------------------------------------------
.686
.MMX
.XMM
.x64

option casemap : none
option win64 : 11
option frame : auto
option stackbase : rsp

_WIN64 EQU 1
WINVER equ 0501h

DEBUG64 EQU 1

;IFDEF DEBUG64
;    PRESERVEXMMREGS equ 1
;    includelib \UASM\lib\x64\Debug64.lib
;    DBG64LIB equ 1
;    DEBUGEXE textequ <'\UASM\bin\DbgWin.exe'>
;    include \UASM\include\debug64.inc
;    .DATA
;    RDBG_DbgWin	DB DEBUGEXE,0
;    .CODE
;ENDIF

;UNICODE EQU 1 ; uncomment to use unicode, otherwise ansi

Include MOSViewer.inc ; plugin's include file

Include DOpusSDKx64.inc ; Main SDK for your program, and prototypes for the main exports 

;=====================================================================================
CheckMOSFile        PROTO :QWORD
GetMOSDimensions    PROTO :QWORD, :QWORD, :QWORD


RGB MACRO red:REQ, green:REQ, blue:REQ
    EXITM < red or green shl 8 or blue shl 16 >
ENDM


.CODE

;=====================================================================================
; Main entry function for a DLL file  - required.
;-------------------------------------------------------------------------------------
DllMain PROC hinstDLL:HINSTANCE, fdwReason:DWORD, lpvReserved:LPVOID
    .IF fdwReason == DLL_PROCESS_ATTACH
        mov rax, hinstDLL
        mov hInstance, rax
    .ENDIF
    mov rax,TRUE
    ret
DllMain ENDP


;=====================================================================================
; DVP_Init - Called by DOpus when plugin is loaded - needs to be EXPORTED
; 
;-------------------------------------------------------------------------------------
DVP_Init PROC FRAME 
    IFDEF DEBUG64
    Invoke OutputDebugString, CTEXT("MOS::DVP_Init")
    ENDIF
    
    Invoke LoadImage, hInstance, ICO_MOS_LARGE, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hICO_MOS_LARGE, rax
    
    Invoke LoadImage, hInstance, ICO_MOS_SMALL, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hICO_MOS_SMALL, rax

	mov rax, TRUE
	ret
DVP_Init ENDP


;=====================================================================================
; DVP_InitEx - Called by DOpus when plugin is loaded - needs to be EXPORTED
;
;-------------------------------------------------------------------------------------
DVP_InitEx PROC FRAME pInitExData:LPDVPINITEXDATA

    mov rax, TRUE
    ret
DVP_InitEx ENDP


;=====================================================================================
; DVP_USBSafe - Called by DOpus
;
;-------------------------------------------------------------------------------------
DVP_USBSafe PROC FRAME pUSBSafeData:LPOPUSUSBSAFEDATA
	
	mov rax, TRUE
    ret
DVP_USBSafe ENDP


;=====================================================================================
; DVP_Uninit - Called by DOpus when plugin is unloaded - needs to be EXPORTED
; 
;-------------------------------------------------------------------------------------
DVP_Uninit PROC FRAME 

	mov rax, TRUE
	ret
DVP_Uninit ENDP


;=====================================================================================
; DVP_Identify - 
; 
;-------------------------------------------------------------------------------------
DVP_Identify PROC FRAME USES RBX lpVPInfo:LPVIEWERPLUGININFO
    LOCAL cchHandleExtsMax:DWORD
    LOCAL cchNameMax:DWORD
    LOCAL cchDescriptionMax:DWORD
    LOCAL cchURLMax:DWORD
    LOCAL lpszHandleExts:QWORD
    LOCAL lpszName:QWORD
    LOCAL lpszDescription:QWORD
    LOCAL lpszURL:QWORD
    LOCAL lpidPlugin:QWORD
    
    IFDEF DEBUG64
    Invoke OutputDebugString, CTEXT("MOS::DVP_Identify")
    ENDIF

    mov rbx, lpVPInfo
    mov eax, dword ptr [rbx].VIEWERPLUGININFO.cchHandleExtsMax
    mov cchHandleExtsMax, eax
    mov eax, dword ptr [rbx].VIEWERPLUGININFO.cchNameMax
    mov cchNameMax, eax
    mov eax, dword ptr [rbx].VIEWERPLUGININFO.cchDescriptionMax
    mov cchDescriptionMax, eax
    mov eax, dword ptr [rbx].VIEWERPLUGININFO.cchURLMax
    mov cchURLMax, eax
    mov rax, [rbx].VIEWERPLUGININFO.lpszHandleExts
    mov lpszHandleExts, rax
    mov rax, [rbx].VIEWERPLUGININFO.lpszName
    mov lpszName, rax
    mov rax, [rbx].VIEWERPLUGININFO.lpszDescription
    mov lpszDescription, rax
    mov rax, [rbx].VIEWERPLUGININFO.lpszURL
    mov lpszURL, rax
    
    lea rax, [rbx].VIEWERPLUGININFOA.idPlugin
    mov lpidPlugin, rax
    
    ; note multi-threading on causes thumbnails to show graphical artifacts / corruption, so have to disable that
    mov rax, DVPFIF_CanHandleBytes or DVPFIF_UseVersionResource or DVPFIF_ExtensionsOnlyIfSlow or DVPFIF_ExtensionsOnlyIfNoRndSeek or DVPFIF_ExtensionsOnlyForThumbnails or DVPFIF_NoProperties or DVPFIF_NoMultithreadThumbnails
    mov [rbx].VIEWERPLUGININFOA.dwFlags, eax
    mov eax, DVPMajorType_Image
    mov [rbx].VIEWERPLUGININFOA.uiMajorFileType, eax
    
    .IF lpszHandleExts != 0
        Invoke lstrcpyn, lpszHandleExts, Addr szMOSExt, cchHandleExtsMax
    .ENDIF
    .IF lpszName != 0
        Invoke lstrcpyn, lpszName, Addr szMOSFile, cchNameMax
    .ENDIF
    .IF lpszDescription != 0
        Invoke lstrcpyn, lpszDescription, Addr szMOSViewerInfo, cchDescriptionMax
    .ENDIF
    .IF lpszURL != 0
        Invoke lstrcpyn, lpszURL, Addr szMOSURL, cchURLMax
    .ENDIF
    Invoke RtlMoveMemory, lpidPlugin, Addr MOSViewerGUID, SIZEOF MOSViewerGUID

    
    mov rbx, lpVPInfo
    .IF hICO_MOS_SMALL != 0
        mov rax, hICO_MOS_SMALL
        mov [rbx].VIEWERPLUGININFOA.hIconSmall, rax
    .ENDIF
    .IF hICO_MOS_LARGE != 0
        mov rax, hICO_MOS_LARGE
        mov [rbx].VIEWERPLUGININFOA.hIconLarge, rax
    .ENDIF
	mov rax, TRUE
	ret
DVP_Identify ENDP


;=====================================================================================
; DVP_IdentifyFile - 
; 
;-------------------------------------------------------------------------------------
DVP_IdentifyFile PROC FRAME hWnd:HWND, lpszName:QWORD, lpVPFileInfo:LPVIEWERPLUGINFILEINFO, hAbortEvent:HANDLE
    Invoke OutputDebugString, CTEXT("MOS::DVP_IdentifyFile")
    
	mov rax, TRUE
	ret
DVP_IdentifyFile ENDP


;=====================================================================================
; DVP_IdentifyFileStream - 
; 
;-------------------------------------------------------------------------------------
DVP_IdentifyFileStream PROC FRAME hWnd:HWND, lpStream:LPSTREAM, lpszName:QWORD, lpVPFileInfo:LPVIEWERPLUGINFILEINFO, dwStreamFlags:DWORD

	mov rax, TRUE
	ret
DVP_IdentifyFileStream ENDP


;=====================================================================================
; DVP_IdentifyFileBytes - 
; 
;-------------------------------------------------------------------------------------
DVP_IdentifyFileBytes PROC FRAME USES RBX hWnd:HWND, lpszName:QWORD, lpData:LPBYTE, uiDataSize:UINT, lpVPFileInfo:LPVIEWERPLUGINFILEINFO, dwStreamFlags:DWORD
    LOCAL hIEMOS:QWORD
    LOCAL qwImageWidth:QWORD
    LOCAL qwImageHeight:QWORD
    LOCAL cchInfoMax:DWORD
    LOCAL lpszInfo:QWORD
    LOCAL MOSType:QWORD
    
    IFDEF DEBUG64
    Invoke OutputDebugString, CTEXT("MOS::DVP_IdentifyFileBytes")
    ENDIF
    
    Invoke CheckMOSFile, lpData
    mov MOSType, rax
    .IF rax == MOS_VERSION_INVALID || rax == MOS_VERSION_MOS_V20
        .IF rax == MOS_VERSION_MOS_V20
            IFDEF DEBUG64
            Invoke OutputDebugString, CTEXT("MOS::DVP_IdentifyFileBytes - Unsupported MOS")
            Invoke OutputDebugString, lpszName
            ENDIF
        .ELSE
            IFDEF DEBUG64
            Invoke OutputDebugString, CTEXT("MOS::DVP_IdentifyFileBytes - Invalid MOS")
            Invoke OutputDebugString, lpszName
            ENDIF
        .ENDIF
        mov rax, FALSE
        ret
    
    .ELSEIF rax == MOS_VERSION_MOSCV10
        IFDEF DEBUG64
        Invoke OutputDebugString, CTEXT("MOS::DVP_IdentifyFileBytes - Valid Compressed MOS")
        Invoke OutputDebugString, lpszName
        ENDIF
        
        Invoke IEMOSOpen, lpszName, IEMOS_MODE_READONLY
        .IF rax == NULL
            mov rax, FALSE
            ret
        .ENDIF
        mov hIEMOS, rax
        
        Invoke IEMOSImageDimensions, hIEMOS, Addr qwImageWidth, Addr qwImageHeight
        
        ; save IEMOS handle to private data
        mov rbx, lpVPFileInfo
        lea rbx, [rbx+8].VIEWERPLUGINFILEINFO.dwPrivateData
        mov rax, hIEMOS
        mov [rbx], rax
        
    .ELSE ; MOS V1
    
        IFDEF DEBUG64
        Invoke OutputDebugString, CTEXT("MOS::DVP_IdentifyFileBytes - Valid MOS")
        Invoke OutputDebugString, lpszName
        ENDIF
        
        Invoke GetMOSDimensions, lpData, Addr qwImageWidth, Addr qwImageHeight
    
    .ENDIF
    
    ; save MOS file type signature to private data
    mov rbx, lpVPFileInfo
    lea rbx, [rbx].VIEWERPLUGINFILEINFO.dwPrivateData
    mov rax, MOSType
    mov [rbx], rax
    
    ; Fill in info about MOS
    mov rbx, lpVPFileInfo
    mov eax, dword ptr [rbx].VIEWERPLUGINFILEINFO.cchInfoMax
    mov cchInfoMax, eax
    mov rax, [rbx].VIEWERPLUGINFILEINFO.lpszInfo
    mov lpszInfo, rax
    
    mov rax, DVPFIF_CanReturnBitmap or DVPFIF_CanReturnViewer or DVPFIF_CanReturnThumbnail ;or DVPFIF_RegenerateOnResize
    mov [rbx].VIEWERPLUGINFILEINFO.dwFlags, eax
    mov rax, DVPMajorType_Image
    mov word ptr [rbx].VIEWERPLUGINFILEINFO.wMajorType, DVPMajorType_Image
    mov word ptr [rbx].VIEWERPLUGINFILEINFO.wMinorType, 0
    mov rax, qwImageWidth
    mov dword ptr [rbx].VIEWERPLUGINFILEINFO.szImageSize.SIZE_.cx_, eax
    mov rax, qwImageHeight
    mov dword ptr [rbx].VIEWERPLUGINFILEINFO.szImageSize.SIZE_.cy, eax
    mov dword ptr [rbx].VIEWERPLUGINFILEINFO.iNumBits, 8;24d
    
    xor rax, rax
    mov eax, RGB(0,255,0)
    mov dword ptr [rbx].VIEWERPLUGINFILEINFO.crTransparentColor, eax
    
    .IF lpszInfo != 0
        .IF MOSType == MOS_VERSION_MOSCV10
            Invoke wsprintf, Addr MOSFileInfoBuffer, Addr szMOSCFormat, qwImageWidth, qwImageHeight, 8
        .ELSE
            Invoke wsprintf, Addr MOSFileInfoBuffer, Addr szMOSFormat, qwImageWidth, qwImageHeight, 8
        .ENDIF
        
        Invoke OutputDebugString, Addr MOSFileInfoBuffer
        Invoke lstrcpyn, lpszInfo, Addr MOSFileInfoBuffer, cchInfoMax
    .ENDIF
    
    ;.IF MOSType == MOS_VERSION_MOSCV10
    ;    Invoke IEMOSClose, hIEMOS
    ;.ENDIF

    mov rax, TRUE
	ret
DVP_IdentifyFileBytes ENDP


;=====================================================================================
; DVP_LoadBitmap - 
; 
;-------------------------------------------------------------------------------------
DVP_LoadBitmap PROC FRAME USES RBX hWnd:HWND, lpszName:QWORD, lpVPFileInfo:LPVIEWERPLUGINFILEINFO, lpszDesiredSize:LPSIZE, hAbortEvent:HANDLE
    LOCAL hIEMOS:QWORD
    LOCAL hMOSBitmap:QWORD
    LOCAL qwWidth:QWORD
    LOCAL qwHeight:QWORD
    LOCAL MOSType:QWORD
    
    IFDEF DEBUG64
    Invoke OutputDebugString, CTEXT("MOS::DVP_LoadBitmap")
    ENDIF
    
    mov hIEMOS, 0
    
    ; Get MOS signature from private data
    mov rbx, lpVPFileInfo
    lea rbx, [rbx].VIEWERPLUGINFILEINFO.dwPrivateData
    mov rax, [rbx]
    mov MOSType, rax
    
    .IF rax == MOS_VERSION_MOSCV10 ; if compressed mos, we had to open it already in DVP_IdentifyFileBytes 
        mov rbx, lpVPFileInfo
        lea rbx, [rbx+8].VIEWERPLUGINFILEINFO.dwPrivateData
        mov rax, [rbx]
        mov hIEMOS, rax
    .ELSE ; otherwise we open the MOS V1 file
        Invoke IEMOSOpen, lpszName, IEMOS_MODE_READONLY
        .IF rax == NULL
            ret
        .ENDIF
        mov hIEMOS, rax
    .ENDIF
    
    ; Check if we need to abort
    .IF hAbortEvent == TRUE
        Invoke WaitForSingleObject, hAbortEvent, 0 
        .IF rax == WAIT_OBJECT_0
            .IF hIEMOS != 0
                Invoke IEMOSClose, hIEMOS
            .ENDIF
            mov rax, NULL
            ret
        .ENDIF
    .ENDIF
    
;    mov rbx, lpszDesiredSize
;    mov eax, dword ptr [rbx].SIZE_.cx_
;    mov qwWidth, rax
;    mov eax, dword ptr [rbx].SIZE_.cy
;    mov qwHeight, rax
    
    ; Create the MOS bitmap image
    Invoke IEMOSBitmap, hIEMOS, 0, 0 ;qwWidth, qwHeight
    .IF rax == NULL
        IFDEF DEBUG64
        Invoke OutputDebugString, CTEXT("MOS::DVP_LoadBitmap - No Bitmap")
        ENDIF
        mov rax, NULL
        ret
    .ENDIF
    mov hMOSBitmap, rax
    
    Invoke IEMOSClose, hIEMOS
    
	mov rax, hMOSBitmap
	ret
DVP_LoadBitmap ENDP


;=====================================================================================
; DVP_LoadBitmapStream - 
; 
;-------------------------------------------------------------------------------------
DVP_LoadBitmapStream PROC FRAME hWnd:HWND, lpStream:LPSTREAM, lpszName:QWORD, lpVPFileInfo:LPVIEWERPLUGINFILEINFO, lpszDesiredSize:LPSIZE, dwStreamFlags:DWORD

	mov rax, TRUE
	ret
DVP_LoadBitmapStream ENDP


;=====================================================================================
; DVP_LoadText - 
; 
;-------------------------------------------------------------------------------------
DVP_LoadText PROC FRAME lpLoadTextData:LPDVPLOADTEXTDATA

	mov rax, TRUE
	ret
DVP_LoadText ENDP


;=====================================================================================
; DVP_ShowProperties - 
; 
;-------------------------------------------------------------------------------------
DVP_ShowProperties PROC FRAME hWndParent:HWND, lpszName:QWORD, lpVPFileInfo:LPVIEWERPLUGINFILEINFO

	mov rax, TRUE
	ret
DVP_ShowProperties ENDP


;=====================================================================================
; DVP_ShowPropertiesStream - 
; 
;-------------------------------------------------------------------------------------
DVP_ShowPropertiesStream PROC FRAME hWndParent:HWND, lpStream:LPSTREAM, lpszName:QWORD, lpVPFileInfo:LPVIEWERPLUGINFILEINFO, dwStreamFlags:DWORD

	mov rax, TRUE
	ret
DVP_ShowPropertiesStream ENDP


;=====================================================================================
; DVP_CreateViewer - 
; 
;-------------------------------------------------------------------------------------
DVP_CreateViewer PROC FRAME hWndParent:HWND, lpRc:LPRECT, dwFlags:DWORD

	mov rax, FALSE
	ret
DVP_CreateViewer ENDP


;=====================================================================================
; DVP_Configure - 
; 
;-------------------------------------------------------------------------------------
DVP_Configure PROC FRAME hWndParent:HWND, hWndNotify:HWND, dwNotifyData:DWORD

	mov rax, TRUE
	ret
DVP_Configure ENDP


;=====================================================================================
; DVP_About - 
; 
;-------------------------------------------------------------------------------------
DVP_About PROC FRAME hWndParent:HWND

	mov rax, TRUE
	ret
DVP_About ENDP


;=====================================================================================
; DVP_GetFileInfoFile - 
; 
;-------------------------------------------------------------------------------------
DVP_GetFileInfoFile PROC FRAME hWnd:HWND, lpszName:QWORD, lpVPFileInfo:LPVIEWERPLUGINFILEINFO, lpFIH:LPDVPFILEINFOHEADER, hAbortEvent:HANDLE

	mov rax, TRUE
	ret
DVP_GetFileInfoFile ENDP


;=====================================================================================
; DVP_GetFileInfoFileStream - 
; 
;-------------------------------------------------------------------------------------
DVP_GetFileInfoFileStream PROC FRAME hWnd:HWND, lpStream:LPSTREAM, lpszName:QWORD, lpVPFileInfo:LPVIEWERPLUGINFILEINFO, lpFIH:LPDVPFILEINFOHEADER, dwStreamFlags:DWORD

	mov rax, TRUE
	ret
DVP_GetFileInfoFileStream ENDP

;-------------------------------------------------------------------------------------
; Check MOS file signature from file header data
; Called from DVP_IdentifyFileBytes
; pMOS param is 256 bytes of file header data (lpData)
; Returns: 0 = No Mos file, 1 = MOS V1, 2 = MOS V2, 3 = MOSCV1
; Currently only MOS V1 and MOSC V1 are supported by the IEMOS library
;-------------------------------------------------------------------------------------
CheckMOSFile PROC FRAME USES RBX pMOS:QWORD
    ; check signatures to determine version
    mov rbx, pMOS
    mov eax, [rbx]
    .IF eax == ' SOM' ; MOS
        add rbx, 4
        mov eax, [rbx]
        .IF eax == '  1V' ; V1.0
            mov eax, MOS_VERSION_MOS_V10
        .ELSEIF eax == '  2V' ; V2.0
            mov eax, MOS_VERSION_MOS_V20
        .ELSE
            mov eax, MOS_VERSION_INVALID
        .ENDIF

    .ELSEIF eax == 'CSOM' ; MOSC
        add rbx, 4
        mov eax, [rbx]
        .IF eax == '  1V' ; V1.0
            mov eax, MOS_VERSION_MOSCV10
        .ELSE
            mov eax, MOS_VERSION_INVALID
        .ENDIF            
    .ELSE
        mov eax, MOS_VERSION_INVALID
    .ENDIF
    ret
CheckMOSFile ENDP


;-------------------------------------------------------------------------------------
; Get the MOS image dimensions from the file header data
; Called from DVP_IdentifyFileBytes
; pMOS param is 256 bytes of file header data (lpData)
; Returns: buffers pointed to by lpqwImageWidth and lpqwImageHeight will contain
; image dimensions on success, or 0 otherwise
;-------------------------------------------------------------------------------------
GetMOSDimensions PROC FRAME USES RBX pMOS:QWORD, lpqwImageWidth:QWORD, lpqwImageHeight:QWORD
    LOCAL qwImageWidth:QWORD
    LOCAL qwImageHeight:QWORD
    
    mov qwImageWidth, 0
    mov qwImageHeight, 0
    
    mov rbx, pMOS
    .IF rbx != NULL
        movzx rax, word ptr [rbx].MOSV1_HEADER.ImageWidth
        mov qwImageWidth, rax
        movzx rax, word ptr [rbx].MOSV1_HEADER.ImageHeight
        mov qwImageHeight, rax
    .ENDIF
    .IF lpqwImageWidth != NULL
        mov rbx, lpqwImageWidth
        mov rax, qwImageWidth
        mov [rbx], rax
    .ENDIF
    .IF lpqwImageHeight != NULL
        mov rbx, lpqwImageHeight
        mov rax, qwImageHeight
        mov [rbx], rax
    .ENDIF
    
    xor rax, rax
    ret
GetMOSDimensions ENDP



END DllMain











