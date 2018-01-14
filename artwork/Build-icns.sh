#!/bin/bash

origimg=ketcindy_icon.png

sips -z 1024 1024 ${origimg}  --out ketcindy.iconset/icon_512x512@2x.png
sips -z 512 512   ${origimg}  --out ketcindy.iconset/icon_512x512.png
sips -z 512 512   ${origimg}  --out ketcindy.iconset/icon_256x256@2x.png
sips -z 256 256   ${origimg}  --out ketcindy.iconset/icon_256x256.png
sips -z 256 256   ${origimg}  --out ketcindy.iconset/icon_128x128@2x.png
sips -z 128 128   ${origimg}  --out ketcindy.iconset/icon_128x128.png
sips -z 64 64   ${origimg}  --out ketcindy.iconset/icon_32x32@2x.png
sips -z 32 32   ${origimg}  --out ketcindy.iconset/icon_32x32.png
sips -z 32 32   ${origimg}  --out ketcindy.iconset/icon_16x16@2x.png
sips -z 16 16   ${origimg}  --out ketcindy.iconset/icon_16x16.png

iconutil -c icns ketcindy.iconset

exit

　１、【サイズ】 1024 × 1024　　【保存名】icon_512x512@2x.png 
　２、【サイズ】  512 ×  512　 　【保存名】icon_512x512.png 
　３、【サイズ】  512 ×  512　 　【保存名】icon_256x256@2x.png 
　４、【サイズ】  256 ×  256　 　【保存名】icon_256x256.png 
　５、【サイズ】  256 ×  256　 　【保存名】icon_128x128@2x.png 
　６、【サイズ】  128 ×  128　 　【保存名】icon_128x128.png 
　７、【サイズ】   64 ×   64　  　【保存名】icon_32x32@2x.png 
　８、【サイズ】   32 ×   32　  　【保存名】icon_32x32.png 
　９、【サイズ】   32 ×   32　  　【保存名】icon_16x16@2x.png 
１０、【サイズ】   16 ×   16　  　【保存名】icon_16x16.png 
