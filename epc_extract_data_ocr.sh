#!/bin/bash
# Luke Blunden 2016
# Extract data from a PDF

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# get pdfs to convert
#pwd | find -name '*.txt' > txtlist.txt 

echo '"addr","pcode","refn","sapv","is_rds","is_new","is_ocr","year","month","main_type","sub_type","sub_sub_type","tfa","is_flor","is_solf","is_susf","is_oprb","is_extn","is_uhtd","is_uvf","is_wall","is_solw","is_cavw","is_sysw","is_timw","is_uvw","is_roof","is_flar","is_pitr","is_opra","is_uvr","shd","whd"' > epc_data.csv

while read tf ; do
    #tf="'$(echo $tf)'"
	echo $tf
    # has the file been ocr'ed?
    is_ocr=$(echo $tf | grep -E "_OCR" | wc -l)

    # address
    addr=$(echo $tf | sed -r -e 's/_OCR//g' -e 's/\.txt//g' -e 's:txt/::g')

    # postcode
    pcode=$(echo $tf | grep -E -o "SO[[:digit:]]{2,3}[A-Z]{2}" | sed 's/\(.*\)\(.\{3\}\)$/\1 \2/')

    # dwelling type
    dtype=$(cat $tf | grep -E -o -i "dwelling type:.*")
    # main types (RdSAP, 2005)
    is_hou=$(echo $dtype | grep -E -i "house" | wc -l)
    is_bun=$(echo $dtype | grep -E -i "bungalow" | wc -l)
    is_mas=$(echo $dtype | grep -E -i "maisonette" | wc -l)
    is_fla=$(echo $dtype | grep -E -i "flat" | wc -l)
    # sub-types
    is_sem=$(echo $dtype | grep -E -i "semi" | wc -l)
    is_det=$(echo $dtype | grep -E -i "detached" | wc -l)
    is_end=$(echo $dtype | grep -E -i "end.{0,1}terr" | wc -l)
    is_mid=$(echo $dtype | grep -E -i "mid.{0,1}terr" | wc -l)
    is_ene=$(echo $dtype | grep -E -i "enclosed.{0,1}end.{0,1}terr" | wc -l)
    is_enm=$(echo $dtype | grep -E -i "enclosed.{0,1}end.{0,1}terr" | wc -l)
    # sub-sub-types
    is_mif=$(echo $dtype | grep -E -i "mid.{0,1}floor" | wc -l)
    is_gro=$(echo $dtype | grep -E -i "ground.{0,1}floor" | wc -l)
    is_top=$(echo $dtype | grep -E -i "top.{0,1}floor" | wc -l)
    is_bas=$(echo $dtype | grep -E -i "basement" | wc -l)

    # categorize according to basic types
    if [ "$is_hou" "-eq" "1" ]; then
	main_type=1 # houses
    elif [ "$is_bun" "-eq" "1" ]; then
	main_type=2 # bungalows
    elif [ "$is_mas" "-eq" "1" ]; then
	main_type=3 # maisonettes
    elif [ "$is_fla" "-eq" "1" ]; then
	main_type=4 # flats
    else
	main_type=0
    fi

    if [[ "$is_det" -eq "1" && "$is_sem" -ne "1" ]]; then
	sub_type=1 # detached
    elif [[ "$is_det" -eq "1" && "$is_sem" -eq "1" ]]; then
	sub_type=2 # semi-detached
    elif [ "$is_end" "-eq" "1" ]; then
	sub_type=3 # end of terrace 
    elif [ "$is_mid" "-eq" "1" ]; then
	sub_type=4 # mid-terrace
    elif [ "$is_ene" "-eq" "1" ]; then
	sub_type=5 # enclosed end of terrace 
    elif [ "$is_enm" "-eq" "1" ]; then
	sub_type=6 # enclosed mid-terrace
    else
	sub_type=0
    fi

    if [ "$is_bas" "-eq" "1" ]; then
	sub_sub_type=1 # basement
    elif [ "$is_gro" "-eq" "1" ]; then
	sub_sub_type=2 # ground floor
    elif [ "$is_mif" "-eq" "1" ]; then
	sub_sub_type=3 # mid floor
    elif [ "$is_top" "-eq" "1" ]; then
	sub_sub_type=4 # top floor
    else
	sub_sub_type=0
    fi

    # date
    adate=$(cat $tf | grep -o -E -i "date of assessment: .*")
    year=$(echo $adate | grep -E -o "20[01][0-9]")
    month=$(echo $adate | grep -E -o '[/][0-9]{1,2}[/]' | sed -r -e 's:/::g' -e 's/0//g')
    is_jan=$(echo $adate | grep -E -i "jan" | wc -l)
    is_feb=$(echo $adate | grep -E -i "feb" | wc -l)
    is_mar=$(echo $adate | grep -E -i "mar" | wc -l)
    is_apr=$(echo $adate | grep -E -i "apr" | wc -l)
    is_may=$(echo $adate | grep -E -i "may" | wc -l)
    is_jun=$(echo $adate | grep -E -i "jun" | wc -l)
    is_jul=$(echo $adate | grep -E -i "jul" | wc -l)
    is_aug=$(echo $adate | grep -E -i "aug" | wc -l)
    is_sep=$(echo $adate | grep -E -i "sep" | wc -l)
    is_oct=$(echo $adate | grep -E -i "oct" | wc -l)
    is_nov=$(echo $adate | grep -E -i "nov" | wc -l)
    is_dec=$(echo $adate | grep -E -i "dec" | wc -l)
    if [ "$is_jan" "-eq" "1" ]; then
	month=1
    elif [ "$is_feb" "-eq" "1" ]; then
	month=2
    elif [ "$is_mar" "-eq" "1" ]; then
	month=3
    elif [ "$is_apr" "-eq" "1" ]; then
	month=4
    elif [ "$is_may" "-eq" "1" ]; then
	month=5
    elif [ "$is_jun" "-eq" "1" ]; then
	month=6
    elif [ "$is_jul" "-eq" "1" ]; then
	month=7
    elif [ "$is_aug" "-eq" "1" ]; then
	month=8
    elif [ "$is_sep" "-eq" "1" ]; then
	month=9
    elif [ "$is_oct" "-eq" "1" ]; then
	month=10
    elif [ "$is_nov" "-eq" "1" ]; then
	month=11
    elif [ "$is_dec" "-eq" "1" ]; then
	month=12
    elif [ "-z" "$month" ]; then
	month=0
    fi

    # 20-digit unique reference number
    refn=$(cat $tf | grep -o -E -i "reference number:.*" | sed -r -e 's/[^[:digit:]Oo]//g' -e 's/[oO]/0/g' | sort -u)

    # SAP version (if present)
    sapv=$(cat $tf | grep -E -i -o "sap[^[:digit:]]*9.8[0-9]" | sed -r 's/[Ss][Aa][Pp][^[:digit:]]*(9.8[0-9]).*/\1/' | sort -u)
    if [ "-z" "$sapv" ]; then
	sapv=0
    fi
    is_rds=$(cat $tf | grep -E -i -o "rdsap" | sort -u -f | wc -l)
    if [ "$is_rds" "-eq" "0" ]; then
	is_new=$(cat $tf | grep -E -i -o "new dwelling" | sort -u | wc -l)
    else
	is_new=0
    fi

    # total floor area
    tfa=$(cat $tf | grep -o -i -E "(total|(total floor area))[[:space:]:]*[[:digit:]]{1}[[:digit:][:space:].]{1}.*m.*" | sed -r 's/^[^[:digit:]]+([[:digit:]]+).+/\1/')

    # floor type
    floors=$(cat $tf | grep -E -i -A 1 -B 1 "^[^[:alnum:]]*floor" | grep -i -E -o "(solid|suspended|(other premises below)|unheated|external)")
    is_solf=$(echo $floors | grep -E -i -o "solid" | wc -l)
    is_susf=$(echo $floors | grep -E -i -o "suspended" | wc -l)
    is_oprb=$(echo $floors | grep -E -i -o "other premises below" | wc -l)
    is_extn=$(echo $floors | grep -E -i -o "external" | wc -l)
    is_uhtd=$(echo $floors | grep -E -i -o "unheated" | wc -l)
    is_uvaf=$(echo $floors | grep -E -i -o "average thermal transmittance" | wc -l)
    is_flor=$(($is_solf || $is_susf || $is_oprb || $is_extn || $is_uhtd || $is_uvaf))

    # wall type
    walls=$(cat $tf | grep -E -i -A 1 -B 1 "^[^[:alnum:]]*walls" | grep -i -E -o "^[^[:alnum:]]*(walls)*[^[:alnum:]]*(solid|stone|cavity|(system[s]* built)|(average thermal transmittance [[:digit:].]+)|timber)")
    is_solw=$(echo $walls | grep -E -i -o "solid" | wc -l)
    is_cavw=$(echo $walls | grep -E -i -o "cavity" | wc -l)
    is_sysw=$(echo $walls | grep -E -i -o "system" | wc -l)
    is_timw=$(echo $walls | grep -E -i -o "timber" | wc -l)
    is_stow=$(echo $walls | grep -E -i -o "stone" | wc -l)
    is_uvaw=$(echo $walls | grep -E -i -o "average thermal transmittance" | wc -l)
    is_wall=$(($is_solw || $is_cavw || $is_sysw || $is_timw || $is_uvaw))

    # roof type
    roofs=$(cat $tf | grep -E -i -A 1 -B 1 "^[^[:alnum:]]*roof" | grep -i -E -o "^[^[:alnum:]]*(roof[s]*)*[^[:alnum:]]*(pitched|flat|(other premises above)|(another dwelling above)|(average thermal transmittance [[:digit:].]+))")
    is_pitr=$(echo $roofs | grep -E -i -o "pitched" | wc -l)
    is_flar=$(echo $roofs | grep -E -i -o "flat" | wc -l)
    is_opra=$(echo $roofs | grep -E -i -o "((other premises above)|(another dwelling above))" | wc -l)
    is_uvar=$(echo $roofs | grep -E -i -o "average thermal transmittance" | wc -l)
    is_roof=$(($is_pitr || $is_flar || $is_opra || $is_uvar))

	# heating demand (RHI info 2011-)
	shd=$(cat $tf | grep -o -E "Space heating \(kWh per year\)[[:space:]]+[[:digit:],.]+" | awk '{$1=""; $2=""; $3=""; $4=""; $5=""; gsub(/^[ \t]+/,""); print}' | sed -r 's/,//g')
    whd=$(cat $tf | grep -o -E "Water heating \(kWh per year\)[[:space:]]+[[:digit:],.]+" | awk '{$1=""; $2=""; $3=""; $4=""; $5=""; gsub(/^[ \t]+/,""); print}' | sed -r 's/,//g')


	
#    no_inw=$(echo $adate | grep -E -i "no.{0,1}insulation" | wc -l)
#    is_inw=$(echo $adate | grep -E -i "insulated" | wc -l)
    #eu=$(cat $ft | grep -E "((Energy use)|(Primary energy use))[[:space:]]{2,}")
    #euc=$(echo $eu | sed -r 's/[^[:digit:]]+([[:digit:].,]+)[^[:digit:]]+([[:digit:].,]+).*/\1/')
    #eup=$(echo $eu | sed -r 's/[^[:digit:]]+([[:digit:].,]+)[^[:digit:]]+([[:digit:].,]+).*/\2/')
   # co2e=$(cat $ft | grep -o -E "Carbon dioxide emissions[[:space:]]{2,}")
    #co2ec=$(echo $co2e | sed -r 's/[^[:digit:]]+([[:digit:].,]+)[^[:digit:]]+([[:digit:].,]+).*/\1/')
    #co2ep=$(echo $co2e | sed -r 's/[^[:digit:]]+([[:digit:].,]+)[^[:digit:]]+([[:digit:].,]+).*/\2/')   
    #floor=$(cat $tf | grep -o -E "^[[:space:]]*Floor[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; gsub(/^[ \t]+/,""); print}')
    #wind=$(cat $tf | grep -o -E "^[[:space:]]*Windows[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; gsub(/^[ \t]+/,""); print}')
   # heat1=$(cat $tf | grep -o -E "^[[:space:]]*Main heating[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; gsub(/^[ \t]+/,""); print}')
    #heat1c=$(cat $tf | grep -o -E "^[[:space:]]*Main heating controls[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; $3=""; gsub(/^[ \t]+/,""); print}')
    #heat2=$(cat $tf | grep -o -E "^[[:space:]]*Secondary heating[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; gsub(/^[ \t]+/,""); print}')
    #hwat=$(cat $tf | grep -o -E "^[[:space:]]*Hot water[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; gsub(/^[ \t]+/,""); print}')
    #light=$(cat $tf | grep -o -E "^[[:space:]]*Lighting[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; gsub(/^[ \t]+/,""); print}')
    #tight=$(cat $tf | grep -o -E "^[[:space:]]*Air tightness[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; gsub(/^[ \t]+/,""); print}')
    #ceer=$(cat $tf | grep -o -E "^[[:space:]]*Current energy efficiency rating[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; $3=""; $4=""; gsub(/^[ \t]+/,""); print}')
    #ceir=$(cat $tf | grep -o -E "^[[:space:]]*Current environmental impact (CO2 ) rating[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; $3=""; $4=""; $5=""; $6=""; gsub(/^[ \t]+/,""); print}')
    #peer=$(cat $tf | grep -o -E "^[[:space:]]*Potential energy efficiency rating[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; $3=""; $4=""; gsub(/^[ \t]+/,""); print}')
    #peir=$(cat $tf | grep -o -E "^[[:space:]]*Potential environmental impact (CO2 ) rating[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; $3=""; $4=""; $5=""; $6=""; gsub(/^[ \t]+/,""); print}')
    #lzces=$(cat $tf | grep -o -E "Low and zero carbon energy sources[[:space:]]+[[:alnum:]]+[[:space:][:punct:][:alnum:]]*" | awk '{$1=""; $2=""; $3=""; $4=""; $5=""; $6=""; gsub(/^[ \t]+/,""); print}')
    

    # write to data file
    echo \"$addr\",$pcode,$refn,$sapv,$is_rds,$is_new,$is_ocr,$year,$month,$main_type,$sub_type,$sub_sub_type,$tfa,$is_flor,$is_solf,$is_susf,$is_oprb,$is_extn,$is_uhtd,$is_uvaf,$is_wall,$is_solw,$is_cavw,$is_sysw,$is_timw,$is_uvaw,$is_roof,$is_flar,$is_pitr,$is_opra,$is_uvar,$shd,$whd >> epc_data.csv
done < txtlist.txt

IFS=$SAVEIFS