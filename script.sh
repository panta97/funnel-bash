#!/bin/zsh
myArray=()

dateArray=()
timeArray=()
filenameArray=()

# comand running example ./.script.sh "Friday" "16:00" "19:00"
#                                    $1       $2      $3
# then you can move the filtered.txt file to a specific folder
# mv `cat filtered.txt` bunchy

while IFS= read -r line; do
    myArray+=("$line")
done < <(ls -ltU | awk '{print $6$7, $8, $9}')

while IFS= read -r line; do
    dateArray+=("$line")
done < <(ls -ltU | awk '{print $6$7}')
while IFS= read -r line; do
    timeArray+=("$line")
done < <(ls -ltU | awk '{print $8}')
while IFS= read -r line; do
    filenameArray+=("$line")
done < <(ls -ltU | awk '{print $9}')


# Transform add zeros to months

for ((i = 2; i <= ${#dateArray[@]}; ++i)); do
    if [ ${#dateArray[$i]} -eq 4 ];then
        singleDigit=${dateArray[$i]: -1}
        dateArray[$i]=${dateArray[$i]: :-1}
        dateArray[$i]="${dateArray[$i]}0${singleDigit}"
    fi
done

get_weekday () {
    # $1 ls date format
    aux=$(date -j -f '%m-%d-%Y' "$(date -j -f "%b%d%y" "${1}18" +"%m-%d-%Y")" +'%A')
    echo $aux
}


is_in_day_in_hour() {
    # $1 weekday
    # $2 min hour
    # $3 max hour
    # $4 weekday of current item
    # $5 hour day of current item 

    result=""
    if [ "$1" = "$4" ] ; then
        if [[ $5 > $2 ]] && [[ $5 < $3 ]] ; then
            result="true"
            echo $result
        fi
    else
        result="false"
        echo $result
    fi
}

for ((i = 2; i <= ${#dateArray[@]}; ++i)); do

    weekday=$(get_weekday "${dateArray[$i]}")
    hours=${timeArray[$i]}
    filename=${filenameArray[$i]}
    result=$(is_in_day_in_hour $1 $2 $3 $weekday $hours)

    if [ "$result" = "true" ] ; then
        echo "${filenameArray[$i]}" >> filtered.txt
    fi
done