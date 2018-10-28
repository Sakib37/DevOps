#!/bin/bash

KUPA_FILE_CACHE=/vagrant/packages

# The fetch_from_cache function is used to fetch files from the cache.
# If the file does not already exist in the cache it is downloaded to the cache
# The function accepts two arguments:
# - $1 - the download url
# - $2 - the filename override. if this is specified, the name of the file in the cache is set to this value
# usage: fetch_from_cache "http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-8.html" yow.html
function fetch_file {
    DOWNLOAD_URL=$1
    FILENAME_OVERRIDE=$2

    if [ -z ${DOWNLOAD_URL} ]
    then
        echo "error: no download url was provided"
        exit -1
    fi

    if [ -z ${FILENAME_OVERRIDE} ]
    then
        FILE_NAME=$(basename ${DOWNLOAD_URL})
        echo "info: no filename override was provided, set file name from url as ${FILE_NAME}"
    else
        FILE_NAME=$2
        echo "info: filename override specified, set file name as ${FILE_NAME}"
    fi


    CACHE_FILE_LOCATION=${KUPA_FILE_CACHE}/${FILE_NAME}

    if [ ! -f ${CACHE_FILE_LOCATION} ]
    then
        echo "${FILE_NAME} does not exist in cache. fetching it now..."
        wget -q ${DOWNLOAD_URL} -O ${CACHE_FILE_LOCATION}
    else
        echo "${FILE_NAME} exists in cache at ${CACHE_FILE_LOCATION}"
    fi
}



function print_welcome {

    #From the below link, choose "doh" format :
    #http://www.kammerl.de/ascii/AsciiSignature.php
    echo "
        KKKKKKKKK    KKKKKKK     888888888        SSSSSSSSSSSSSSS
        K:::::::K    K:::::K   88:::::::::88    SS:::::::::::::::S
        K:::::::K    K:::::K 88:::::::::::::88 S:::::SSSSSS::::::S
        K:::::::K   K::::::K8::::::88888::::::8S:::::S     SSSSSSS
        KK::::::K  K:::::KKK8:::::8     8:::::8S:::::S
          K:::::K K:::::K   8:::::8     8:::::8S:::::S
          K::::::K:::::K     8:::::88888:::::8  S::::SSSS
          K:::::::::::K       8:::::::::::::8    SS::::::SSSSS
          K:::::::::::K      8:::::88888:::::8     SSS::::::::SS
          K::::::K:::::K    8:::::8     8:::::8       SSSSSS::::S
          K:::::K K:::::K   8:::::8     8:::::8            S:::::S
        KK::::::K  K:::::KKK8:::::8     8:::::8            S:::::S
        K:::::::K   K::::::K8::::::88888::::::8SSSSSSS     S:::::S
        K:::::::K    K:::::K 88:::::::::::::88 S::::::SSSSSS:::::S
        K:::::::K    K:::::K   88:::::::::88   S:::::::::::::::SS
        KKKKKKKKK    KKKKKKK     888888888      SSSSSSSSSSSSSSS
    "
}