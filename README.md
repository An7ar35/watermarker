# Photo watermark/resize script

Script to batch add a SVG watermark to and/or resize JPG files.

### Usage

1. Copy the script and watermark.svg file in a local folder,
2. (optional) Add ````watermarker.sh```` to your ````$PATH```` 
   environment variable to simplify usage.
3. Edit or replace watermark.svg with your watermark*,
4. Run script from the directory of the photos you want to process with the desired flags.

*Make sure to resize the svg to fit content (File > Document properties in 
[Inkscape](docs/inkscape_screenshot.png))

### Flags

    -s  Size of output image (<width>x<height>, <width>x, <height>y)
    -w  SVG file to use as watermark
    -a  Text to append to processed file names
    -o  Output path of processed files (default='watermarker/')
    -h  Shows this usage description
    -x  Shows some usage examples

    
### Example

    $ ./watermarker.sh -w my_watermark.svg -s 1080y -o ~/path_to_output/
    $ ./watermarker.sh -w my_watermark.svg -o ~/path_to_output/
    $ ./watermarker.sh -w my_watermark.svg -a \"_watermarked\"
    $ ./watermarker.sh -s 1080x -o -a \"_x1080\" ~/path_to_output/
    $ ./watermarker.sh -s 1080x1920

### Dependency

The shell script uses the following command line tools: `convert` and `composite` 
([ImageMagick](https://www.imagemagick.org)), `getopts`.


### Final words

If you find this useful or even adapt the script for other things you can show 
some love by starring this repo.
