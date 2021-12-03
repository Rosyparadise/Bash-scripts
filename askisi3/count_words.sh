cd "$(dirname "$(readlink -f "$0")")"
filename=$1
i=0
IFS=' -'
g=$2
touch logs.txt
if [ "$1" = "-h" -o "$1" = "--help" ]; then
    echo "Usage: ~/assignment1/askisi3/count_words.sh [FILE] [NUMBER]"
    echo "Calculates and outputs the n most commonly used words in a text file\n"
    echo "First argument is the file that gets analyzed"
    echo "Second argument corresponds to the number of most used words that will get displayed"

else
    lower=$(grep -n " START OF" $1 | cut -d ':' -f 1)
    upper=$(grep -n " END OF" $1 | cut -d ':' -f 1)
    while read line; do
        i=$((i+1))
        if [ $i -gt $lower ]  && [ $i -lt $upper ]; then
            read -a linearr <<< "$line"
            for n in ${linearr[@]}; do
                if grep -q "'" <<< "$n"; then
                    n="$(echo "$n" | cut -d "'" -f 1)"
                fi
                n="$(echo "$n" | tr -d '[:punct:]' | sed "s/[^[:alpha:]-]//g" | tr '[:upper:]' '[:lower:]' )"
                if  grep -wq "$n" logs.txt  ; then
                        if [ ${#n} -gt 0 ]; then
                            tempnum="$(grep -w ${n} logs.txt | cut -d ' ' -f 1)"
                            tempnum=$((tempnum+1))
                            sed -i -e "s/\b$(grep -w "$n" logs.txt)\b/${tempnum} ${n}/" logs.txt
                        fi
                else
                    if [ ${#n} -gt 0 ]; then
                        echo "1 ${n}" >> logs.txt
                    fi
                fi
            done
        fi
    done < $filename
    tempnum=0
    echo "$(sort -nr logs.txt)"> logs.txt
    while read line; do
        if [ $tempnum -lt $g ]; then
            read -a linearr <<< "$line"
            echo "${linearr[1]} ${linearr[0]}"
            tempnum=$((tempnum+1))
        else
            break
        fi

    done < logs.txt
fi

rm logs.txt
