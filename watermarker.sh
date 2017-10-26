#! /bin/bash

# Tool dependencies: imagemagick (composite, convert), getopts
#Constants
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m' # reset colour

WARNING=${YELLOW}'[Warning]'${RESET}
ERROR=${RED}'[Error]'${RESET}

#Option flags
size_flag=false;
watermark_flag=false;
output_flag=false;
append_flag=false;
#Option variables
image_size="";
watermark_file="";
output_path="";
append_text="";

usage () {
    echo "|===================== Watermarker script v0.2 =====================|"
    echo "|······· Made by An7ar35, 2017 · https://an7ar35.bitbucket.io ······|"
    echo "|===================================================================|"
    echo "  Description:"
    echo "    Script to batch add a SVG watermark to and/or resize JPG files."
    echo "  Usage:"
    echo "    watermarker [-s <w_size>] [-w <watermark vector file>] [-o <path>]"
    echo "  Options:"
    echo "    -s  Size of output image (<width>x<height>, <width>x, <height>y)"
    echo "    -w  SVG file to use as watermark"
    echo "    -a  Text to append to processed file names"
    echo "    -o  Output path of processed files (default='watermarker/')"
    echo "    -h  Shows this usage description"
    echo "    -x  Shows some usage examples";
}

examples() {
    echo "Watermarker example:"
    echo "    $ watermarker.sh -w my_watermark.svg -s 1080y -o ~/path_to_output/"
    echo "    $ watermarker.sh -w my_watermark.svg -o ~/path_to_output/"
    echo "    $ watermarker.sh -w my_watermark.svg -a \"_watermarked\""
    echo "    $ watermarker.sh -s 1080x -o -a \"_x1080\" ~/path_to_output/"
    echo "    $ watermarker.sh -s 1080x1920";
}

while getopts ":s:w:o:a:hx" opt; do
    case $opt in
        s)  printf "${BLUE}| output size.........: $OPTARG${RESET}\n" >&2
            image_size=$OPTARG;
            size_flag=true;
            ;;
        w)  printf "${BLUE}| watermark file......: $OPTARG${RESET}\n" >&2
            watermark_file=$OPTARG;
            watermark_flag=true;
            ;;
        o)  printf "${BLUE}| output path.........: $OPTARG${RESET}\n" >&2
            output_path=$OPTARG;
            output_flag=true;
            ;;
        a)  printf "${BLUE}| filename append text: $OPTARG${RESET}\n" >&2
            append_text=$OPTARG;
            append_flag=true;
            ;;
        h)  usage;
            exit 0
            ;;
        x)  examples;
            exit 0
            ;;
        \?) printf "${ERROR} Invalid option: -$OPTARG\n" >&2
            exit 1
            ;;
        :)  printf "${ERROR} Option -$OPTARG requires an argument.\n" >&2
            exit 1
            ;;
    esac
done

shift $(($OPTIND - 1))

#Checking if either a size or a watermark option was used
if ! $size_flag && ! $watermark_flag; then
    usage;
    exit 1
fi
#Checking watermark file exists if set as option
if $watermark_flag && ! [ -r $watermark_file ]; then
    printf "${ERROR} Watermark file not found. Check path.\n"
    exit 1
fi
#Makes output path directory and checks it
if $output_flag; then
    mkdir -p -- "$output_path"
    if [ $? -ne 0 ]; then
      printf "${ERROR} Failed making $output_path.\n"
      exit 1
    fi
fi

#Checks an output directory was given if there is no text to append
if ! $output_flag && ! $append_flag; then
    printf "${WARNING} Both output directory and append text not provided. One or both must be given to avoid overwrites of the original files.\n"
    exit 1
fi

images=(*.jpg *.JPG)
counter=0

for i in ${images[@]}; do
    
    filename=$(basename "$i")
    extension="${filename##*.}"
    filename="${filename%.*}"
    modified_filename=$filename$append_text'.jpg'

    echo -ne '['${counter}'/'${#images[@]}'] '$i':\r'
    
    if [ -s $i ]; then #non-zero file size
        if $size_flag && ! $watermark_flag; then #resize only
            convert $i -resize $image_size $output_path/$modified_filename
        elif ! $size_flag && $watermark_flag; then #watermarking only
            composite -compose Multiply -density 400 -dissolve 80% -gravity center -background none $watermark_file $i $output_path/$modified_filename
        else #watermarking and resizing.
            composite -compose Multiply -density 400 -dissolve 80% -resize $image_size -gravity center -background none $watermark_file $i $output_path/$modified_filename
        fi
        
        counter=$((counter+1))
        echo -ne '['${counter}'/'${#images[@]}'] '$i': done. ('$output_path'/'$modified_filename')\n'
    else 
        counter=$((counter+1))
        echo -ne '['${counter}'/'${#images[@]}'] '$i': skipped (0 file size).\n'
    fi
done
