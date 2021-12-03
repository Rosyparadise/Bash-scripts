cd "$(dirname "$(readlink -f "$0")")"
filename=$1
i=0
while read line; do
hashcheck=${line:0:1}
i=$((i+1))
if ! [ $hashcheck == "#" ];
    then
    if grep -Fq "$line" webcheck ; then
        if curl -Is "${line}" | grep -wq "200\|301" ; then
            md5temp="$line $(curl -s $line | md5sum | cut -d ' ' -f 1)"
        else
            md5temp="${line} FAILED"
        fi
        md5saved="$(grep $line webcheck)" #gjntrnh
        if ! [ "$md5temp" == "$md5saved" ]; then
            echo "${line}"
            echo "${md5temp}">>webcheck2
        else
            echo "${md5saved}">>webcheck2
        fi
    else
        # code if not found
        if curl -Is "${line}" | grep -wq "200\|301" ; then
            echo "${line} INIT"
            echo "${line} $(curl -s $line | md5sum | cut -d ' ' -f 1)" >> webcheck2
        else
            echo "${line} FAILED" 1>&2
            echo "${line} FAILED" >> webcheck2
        fi
    fi
fi
done < $filename

cp webcheck2 webcheck
echo "" > webcheck2
