# ![](./assets/MOSViewer48x48.png) MOSViewer
Directory Opus Viewer Plugin For MOS File Format

Displays MOS V1.0 and MOSC V1.0 files as bitmap images in tile view or the viewer pane of [Directory Opus](https://www.gpsoft.com.au/)

![](./assets/MOSViewerDemo.png)

MOSViewer was created as an x64 dynamic link library using the [UASM x64](http://www.terraspace.co.uk/uasm.html) assembler. The [Directory Opus Plugin SDK](https://www.gpsoft.com.au/DScripts/download.asp?file=Misc/opus_sdk.zip) was converted to assembler style format for use with this project.

For details on the MOS file format, please visit: [IESDP MOS File Format](https://gibberlings3.github.io/iesdp/file_formats/ie_formats/mos_v1.htm)

## Download

The lastest version can be downloaded in the [releases](https://github.com/mrfearless/MOSViewer/releases) section. 

Note: MOSViewer makes use of the following static libraries: IEMOS, zlib v1.2.11. These are not required to be downloaded for using the MOSViewer plugin.

The lib and include files for each static library and the DOpusSDKx64.inc file are included in the `Required` folder for reference and for building this project. 

## Installation

- Copy MOSViewer.dll to your `GPSoftware\Directory Opus\Viewers` folder
- From the Directory Opus menu: 
	- Settings -> Preferences
	- Navigate to Viewer -> Viewer Plugins
	- Click the refresh icon (the two  arrows)
- You can now view the MOS file format in Directory Opus via the Tile view or in the viewer pane