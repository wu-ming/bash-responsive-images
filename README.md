# bash-responsive-images
is a simple bash script to generate images at different sizes, which can then be used in responsive websites. 

### usage
1. clone the repo or download the zip file.
2. make the script executable: ```chmod +x bash-responsive-images.sh```
3. put the images you want to convert into the **src** folder (works with jpg and png images)
4. execute the script: ```./bash-responsive-images.sh```

the compressed images will be in the **dest** folder, divided in subfolders according to their size.<br>
<br>
Typically you would show the images in an HTML page using the ```scrset``` attribute:
```
<img src="dest/1600/image.png" 
      srcset="dest/320/image.png.png 320w,
              dest/640/image.png 640w,
              dest/960/image.png 960w,
              dest/1280/image.png 1280w,
              dest/1600/image.png 1600w"
      width="0000" height="000" alt="xxx" class="xxx">
 ```

### how it works
First, set the source folder path, the desired sizes for the images, and the destination folder path.
```
SOURCE=src
SIZES=(320 640 960 1280 1600)
DESTINATION=dest
```
You need to manually create the folders (I'll make the process automatic in the next version...). <br>
The folders shouldn't have spaces in their name (~~```source folder```~~ should be ```source_folder```).<br> 
You also need to create a folder for each size, as a subfolder of DESTINATION (e.g. ```dest/320```).
Then
```
for f in "$SOURCE"/*; do
    FILETYPE="${f#*.}" &&
    if [[ "$FILETYPE" == "png" ]]; then
        optipng -quiet "$f"
    else
        jpegoptim "$f"
    fi
```
we detect the file type and optimize it using **optipng** or **jpegoptim**.
```    
FILEWIDTH=$(identify -format %w "$f") &&
FILENAME=$(basename -- "$f") &&
FILESIZE=$(wc -c "$f" | cut -d' ' -f1) &&
``` 
Get the source file width, name an size.
```
for s in ${SIZES[@]}; do
  if [ "$s" -gt "$FILEWIDTH" ]; then
  cp "$f" "$DESTINATION/$s/"
  else
```
If the destination file width exceeds the source file width, we don't compress it, we just copy the original file.
Else, we actually compress and resize the image using imagemagick's **mogrify**:
```
mogrify -path "$DESTINATION/$s" -define png:compression-level=9 -sampling-factor 4:2:0 -strip -quality 85 -interlace plane -colorspace sRGB -resize "$s"x "$f"
```
and then we optimize also the resized image, as we did with the source one.<br> 
The code below is used to overwrite the destination file, in case it's bigger than the source: 
```
FILE2="$DESTINATION/$s/$FILENAME" &&
FILE2NAME=$(basename -- "$FILE2") &&
FILE2SIZE=$(wc -c "$FILE2" | cut -d' ' -f1) &&
  if [[ "$FILE2NAME" == "$FILENAME" ]]; then
    if [ "$FILE2SIZE" -gt "$FILESIZE" ]; then
      rm "$FILE2" &&
      cp "$f" "$DESTINATION/$s/"
```
It's a rare occurence, but can happen with some png files.
        
