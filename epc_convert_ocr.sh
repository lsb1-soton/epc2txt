#!/bin/bash
# Luke Blunden 2016
# Extract text from a PDF

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
while read u; do
    # convert each pdf to text, preserving layout
    echo $u
    tf=$(echo $u | sed 's/pdf/txt/g')
    tfb=$(echo $tf | sed 's/.txt/_OCR/g')
	pdftotext -layout -enc Latin1 $u $tf 2> pdf2txt_err.txt 
    perr=$(cat pdf2txt_err.txt | grep -E "Permission Error: Copying of text from this document is not allowed." | wc -l)
    if [ "$perr" -eq "1" ]; then
	gs -sDEVICE=tiffgray -sOutputFile=tmp/tmp.tif -dNOPAUSE -dBATCH -r900 -q $u
	tesseract tmp/tmp.tif $tfb 2>&1 tess_err.txt
	rm tmp/tmp.tif
    fi
done < convertlist.txt
IFS=$SAVEIFS

