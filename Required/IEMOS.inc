;==============================================================================
;
; IEMOS x64
;
; Copyright (c) 2019 by fearless
;
; http://github.com/mrfearless/InfinityEngineLibraries64
;
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
; Permission is granted to anyone to use this software for any non-commercial 
; program. If you use the library in an application, an acknowledgement in the
; application or documentation is appreciated but not required. 
;
; You are allowed to make modifications to the source code, but you must leave
; the original copyright notices intact and not misrepresent the origin of the
; software. It is not allowed to claim you wrote the original software. 
; Modified files must have a clear notice that the files are modified, and not
; in the original state. This includes the name of the person(s) who modified 
; the code. 
;
; If you want to distribute or redistribute any portion of this package, you 
; will need to include the full package in it's original state, including this
; license and all the copyrights.  
;
; While distributing this package (in it's original state) is allowed, it is 
; not allowed to charge anything for this. You may not sell or include the 
; package in any commercial package without having permission of the author. 
; Neither is it allowed to redistribute any of the package's components with 
; commercial applications.
;
;==============================================================================

;-----------------------------------------------------------------------------------------
; IEMOS Prototypes
;-----------------------------------------------------------------------------------------
IEMOSOpen                   PROTO :QWORD,:QWORD             ; lpszMosFilename, dwOpenMode. Returns in eax a handle used in other functions: hIEMOS
IEMOSMem                    PROTO :QWORD,:QWORD,:QWORD,:QWORD ; pMOSInMemory, lpszMosFilename, dwMosFilesize, dwOpenMode. Returns in eax a handle used in other functions: hIEMOS
IEMOSClose                  PROTO :QWORD                    ; hIEMOS returned from IEMOSOpen.

; Pointers to parts of MOS file:
IEMOSHeader                 PROTO :QWORD                    ; hIEMOS. Returns in eax pointer to a MOSV1_HEADER structure.
IEMOSPalettes               PROTO :QWORD                    ; hIEMOS. Returns in eax pointer to the palettes array
IEMOSTileLookupEntries      PROTO :QWORD                    ; hIEMOS. Returns in eax pointer to TileLookup array entries
IEMOSTileLookupEntry        PROTO :QWORD,:QWORD             ; hIEMOS, nTile. Returns in eax pointer to specific TileLookup entry
IEMOSTileDataEntries        PROTO :QWORD                    ; hIEMOS. Returns in eax pointer to TILEDATA array entries
IEMOSTileDataEntry          PROTO :QWORD,:QWORD             ; hIEMOS, nTile. Returns in eax pointer to specific TILEDATA entry
IEMOSBlockEntries           PROTO :QWORD                    ; hIEMOS. Returns in eax pointer to DATABLOCK_ENTRY array entries. For MOS V2 Only
IEMOSBlockEntry             PROTO :QWORD,:QWORD             ; hIEMOS, nBlockEntry. Returns in eax pointer to a DATABLOCK_ENTRY structure. For MOS V2 Only

; MOS Basic Information:
IEMOSTotalTiles             PROTO :QWORD                    ; hIEMOS. Returns in eax total tiles in MOS
IEMOSTotalPalettes          PROTO :QWORD                    ; hIEMOS. Returns in eax total palettes in MOS (same as total tiles)
IEMOSTotalBlockEntries      PROTO :QWORD                    ; hIEMOS. Returns in eax total no of Datablock entries. For MOS V2 Only
IEMOSImageDimensions        PROTO :QWORD,:QWORD,:QWORD      ; hIEMOS, lpdwImageWidth, lpdwImageHeight
IEMOSColumnsRows            PROTO :QWORD,:QWORD,:QWORD      ; hIEMOS, lpdwColumns, lpdwRows
IEMOSPixelBlockSize         PROTO :QWORD                    ; hIEMOS
IEMOSBitmap                 PROTO :QWORD,:QWORD,:QWORD      ; hIEMOS. Returns in eax HBITMAP (of all combined tiles to create the whole bitmap) or NULL.

; MOS Tile Data Information:
IEMOSTileBitmap             PROTO :QWORD,:QWORD,:QWORD,:QWORD,:QWORD,:QWORD ; hIEMOS, nTile, lpdwTileWidth, lpdwTileHeight, lpdwTileXCoord, lpdwTileYCoord. Returns in eax HBITMAP or NULL
IEMOSTileWidth              PROTO :QWORD,:QWORD             ; hIEMOS, nTile. Returns in tile width
IEMOSTileHeight             PROTO :QWORD,:QWORD             ; hIEMOS, nTile. Returns in tile height
IEMOSTileXCoord             PROTO :QWORD,:QWORD             ; hIEMOS, nTile. Returns in tile x coord
IEMOSTileYCoord             PROTO :QWORD,:QWORD             ; hIEMOS, nTile. Returns in tile y coord
IEMOSTileRAW                PROTO :QWORD,:QWORD             ; hIEMOS, nTile. Returns in pointer to RAW tile data.
IEMOSTilePalette            PROTO :QWORD,:QWORD             ; hIEMOS, nTile. Returns in eax pointer to the tile's specific palette (256 entries of RGBQUADs)
IEMOSTilePaletteValue       PROTO :QWORD,:QWORD,:QWORD      ; hIEMOS, nTile, PaletteIndex. eax contains RGBQUAD or -1 if not valid.

; MOS File & Version Information:
IEMOSFileName               PROTO :QWORD                    ; hIEMOS. Returns in eax pointer to mos full path filename
IEMOSFileNameOnly           PROTO :QWORD,:QWORD             ; hIEMOS, lpszFileNameOnly. eax contains True or false if succesfull. strips filename of path and ext information.
IEMOSFileSize               PROTO :QWORD                    ; hIEMOS. Returns in eax size of mos file in bytes
IEMOSFileCompression        PROTO :QWORD                    ; hIEMOS. Returns in eax -1 = No Mos file, TRUE for MOSCV1, FALSE for MOS V1 or MOS V2 
IEMOSVersion                PROTO :QWORD                    ; hIEMOS. Returns in eax 0 no mos, 1 = MOS V1, 2 = MOS V2, 3 = MOSC 

;-----------------------------------------------------------------------------------------
; IEMOS Structures
;-----------------------------------------------------------------------------------------
IFNDEF MOSV1_HEADER
MOSV1_HEADER            STRUCT
    Signature           DD 0    ; 0x0000 	4 (char array) 	Signature ('MOS ')
    Version             DD 0    ; 0x0004 	4 (char array) 	Version ('V1 ')
    ImageWidth          DW 0    ; 0x0008 	2 (word) 	    Width (pixels)
    ImageHeight         DW 0    ; 0x000a 	2 (word) 	    Height (pixels)
    BlockColumns        DW 0    ; 0x000c 	2 (word) 	    Columns (blocks)
    BlockRows           DW 0    ; 0x000e 	2 (word) 	    Rows (blocks)
    BlockSize           DD 0    ; 0x0010 	4 (dword) 	    Block size (pixels)
    PalettesOffset      DD 0    ; 0x0014 	4 (dword) 	    Offset (from start of file) to palettes
MOSV1_HEADER            ENDS
ENDIF

IFNDEF MOSV2_HEADER
MOSV2_HEADER            STRUCT
    Signature           DD 0    ; 0x0000 	4 (char array) 	Signature ('MOS ')
    Version             DD 0    ; 0x0004 	4 (char array) 	Version ('V2 ')
    ImageWidth          DD 0    ; 0x0008 	4 (dword) 	    Width (pixels)
    ImageHeight         DD 0    ; 0x000c 	4 (dword) 	    Height (pixels)
    BlockEntriesCount   DD 0    ; 0x0010 	4 (dword) 	    Number of data blocks
    BlockEntriesOffset  DD 0    ; 0x0014 	4 (dword) 	    Offset to data blocks
MOSV2_HEADER            ENDS
ENDIF

IFNDEF MOSC_HEADER
MOSC_HEADER             STRUCT
    Signature           DD 0    ; 0x0000   4 (bytes)        Signature ('MOSC')
    Version             DD 0    ; 0x0004   4 (bytes)        Version ('V1 ')
    UncompressedLength  DD 0    ; 0x0008   4 (dword)        Uncompressed data length
MOSC_HEADER             ENDS
ENDIF

IFNDEF TILELOOKUP_ENTRY
TILELOOKUP_ENTRY        STRUCT
    TileDataOffset      DD 0    ; Offset to specific tile's data pixels from start of Tile Data ( Offset Palettes + (Size Palettes) + (Size TilelookupEntries) )
TILELOOKUP_ENTRY        ENDS
ENDIF

IFNDEF TILEDATA
TILEDATA                STRUCT
    TileX               DQ 0
    TileY               DQ 0
    TileW               DQ 0
    TileH               DQ 0
    TileSizeRAW         DQ 0
    TileSizeBMP         DQ 0
    TilePalette         DQ 0
    TileRAW             DQ 0
    TileBMP             DQ 0
    TileBitmapHandle    DQ 0
TILEDATA                ENDS
ENDIF

IFNDEF DATABLOCK_ENTRY  ; Used in MOS V2
DATABLOCK_ENTRY         STRUCT
    PVRZPage            DD 0
    SourceXCoord        DD 0
    SourceYCoord        DD 0
    FrameWidth          DD 0
    FrameHeight         DD 0
    TargetXCoord        DD 0
    TargetYCoord        DD 0
DATABLOCK_ENTRY         ENDS
ENDIF


.CONST

IEMOS_ALIGN                 TEXTEQU <ALIGN 16>
; IEMOSOpen open mode:
IEMOS_MODE_WRITE            EQU 0
IEMOS_MODE_READONLY         EQU 1
; MOS Versions:
MOS_VERSION_INVALID         EQU 0 ; Not a MOS or invalid
MOS_VERSION_MOS_V10         EQU 1 ; MOS_V1.0
MOS_VERSION_MOS_V20         EQU 2 ; MOS_V2.0
MOS_VERSION_MOSCV10         EQU 3 ; MOSCV1.0 (Compressed Blocks)








