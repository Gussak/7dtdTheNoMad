#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

#strFl="$1"
#strFlOut="${1%.xcf}.png"

function FUNCconv() {
  
  astrOpt=(
    "7dtd*.xcf"        160 160
    "NavObj_7dtd*.xcf"  32  32
  )
  for((i=0;i<${#astrOpt[@]};i+=3));do
    strFilter="${astrOpt[i]}"
    strW="${astrOpt[i+1]}"
    strH="${astrOpt[i+2]}"
    strScriptScale="(gimp-image-scale-full image ${strW} ${strH} INTERPOLATION-CUBIC)"
    # https://stackoverflow.com/a/5846727/1422630 (that code was adapted to fit here)
    gimp -n -i -b - <<EOF
    (let* ( (file's (cadr (file-glob "${strFilter}" 1))) (filename "") (image 0) (layer 0) )
      (while (pair? file's) 
        (set! image (car (gimp-file-load RUN-NONINTERACTIVE (car file's) (car file's))))
        (set! layer (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
        ${strScriptScale}
        (set! filename (string-append (substring (car file's) 0 (- (string-length (car file's)) 4)) ".png"))
        (gimp-file-save RUN-NONINTERACTIVE image layer filename filename)
        (gimp-image-delete image)
        (set! file's (cdr file's))
        )
      (gimp-quit 0)
      )
EOF
  done
}

(cd UIAtlases/ItemIconAtlas;FUNCconv)
(cd UIAtlases/UIAtlas      ;FUNCconv)
