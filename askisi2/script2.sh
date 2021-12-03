cd "$(dirname "$(readlink -f "$0")")"
mkdir temp
tar -xf $1 -C temp
validrepos=()
find temp -type f -path "*.txt" > tempnames

while read line; do
    gitname="$(grep -wm1 "https" $line)"
    git clone $gitname assignments/$(basename $gitname) >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "${gitname}: Cloning OK"
        validrepos+=("$(basename $gitname)")
    else
        echo "${gitname}: Cloning FAILED"
    fi
done < tempnames

rm -r temp

for i in "${validrepos[@]}"; do
    echo "$i:"
    nodir=$(find assignments/$i -mindepth 1 -type d -not -path "*/\.git*" | wc -l); echo "Number of directories: $nodir"
    notxt=$(find assignments/$i -type f -not -path "/.git" -path "*.txt" -print | wc -l); echo "Number of txt files: $notxt"
    nodiff=$(find assignments/$i -type f -not -path "*/.git/*" -not -path "*.txt" -print | wc -l); echo "Number of other files: $nodiff"

    if [ $notxt -eq 3 ] && [ $nodiff -eq 0 ] && [ $(find assignments/$i -maxdepth 1 -type f -not -path "*/.git*" | grep -w 'dataA.txt$') ] && [ $nodir -eq 1 ] && [ $(find assignments/$i -mindepth 1 -type f -not -path "*/.git*" | grep -w 'dataB.txt$') ] && [ $(find assignments/$i -mindepth 1 -type f -not -path "*/.git*" | grep -w 'dataC.txt$') ]; then
        echo "Directory structure is OK."
    else
        echo "Directory structure is NOT OK."
    fi
done
rm -rf assignments/*
