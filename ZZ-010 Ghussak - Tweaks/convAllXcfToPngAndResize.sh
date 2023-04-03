#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

#strFl="$1"
#strFlOut="${1%.xcf}.png"

function FUNCconv() {
  strScriptScale="(gimp-image-scale-full image 160 160 INTERPOLATION-CUBIC)"

  # https://stackoverflow.com/a/5846727/1422630
  gimp -n -i -b - <<EOF
  (let* ( (file's (cadr (file-glob "*.xcf" 1))) (filename "") (image 0) (layer 0) )
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
}

(cd UIAtlases/ItemIconAtlas;FUNCconv)
(cd UIAtlases/UIAtlas      ;FUNCconv)
