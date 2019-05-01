#!/bin/bash
# Set the source folder here, be sure there's NO_SPACES in the folder's name!
# Put the images you want to compress into the folder. 
SOURCE=src
# Set the desired sizes for the compressed images
SIZES=(320 640 960 1280 1600)
# Set the destination folder here, be sure there's NO_SPACES in the folder's name!
# The compressed images will be in $DESTINATION/$SIZE
DESTINATION=dest

for f in "$SOURCE"/*; do
    echo &&
    FILETYPE="${f#*.}" &&
    echo "optimizing '$f'" &&
    if [[ "$FILETYPE" == "png" ]]; then
        optipng -quiet "$f"
    else
        jpegoptim "$f"
    fi
    # assign $(command) to VARIABLE
    FILEWIDTH=$(identify -format %w "$f") &&
    FILENAME=$(basename -- "$f") &&
    FILESIZE=$(wc -c "$f" | cut -d' ' -f1) &&
    
    for s in ${SIZES[@]}; do
        # if the destination file width exceeds the original file width, just copy the original file
        if [ "$s" -gt "$FILEWIDTH" ]; then
        echo "'$f' is smaller than $s px, copying it to '$DESTINATION/$s/'..." &&
        cp "$f" "$DESTINATION/$s/"
        else
        # compress the file
        echo "creating '$DESTINATION/$s/$FILENAME'" &&
        mogrify -path "$DESTINATION/$s" -define png:compression-level=9 -sampling-factor 4:2:0 -strip -quality 85 -interlace plane -colorspace sRGB -resize "$s"x "$f" &&
            # optimize the .png file
            if [[ "$FILETYPE" == "png" ]]; then
                echo "optimizing '$DESTINATION/$s/$FILENAME'" &&
                optipng -quiet "$DESTINATION/$s/$FILENAME"
            fi
            # optimize the .jpg file 
            # made no difference in the tests, so it's commented out
            #~ if [[ "$FILETYPE" == "jpg" ]]; then
                #~ jpegoptim "$DESTINATION/$s/$FILENAME"
            #~ fi
        fi
        FILE2="$DESTINATION/$s/$FILENAME" &&
        FILE2NAME=$(basename -- "$FILE2") &&
        FILE2SIZE=$(wc -c "$FILE2" | cut -d' ' -f1) &&
        if [[ "$FILE2NAME" == "$FILENAME" ]]; then
            # if the compressed file is bigger than the original file (it's rare, but can happen), overwrite it with the original file
            if [ "$FILE2SIZE" -gt "$FILESIZE" ]; then
            echo "'$FILE2' is bigger than '$f', copying '$f' to '$DESTINATION/$s'..." &&
            rm "$FILE2" &&
            cp "$f" "$DESTINATION/$s/"
            fi
        fi 
    done
done
