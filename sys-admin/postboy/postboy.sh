#!/usr/bin/env bash

# Get all possible arguments
# -u: Base URL
# -m: Request method
# -e: endpoint
# -b: Bearer Token
# -d: Request Body
# -h..k: Headers

# Set Strings to build
CURL_CMD="curl --silent --location "
FULL_URL=""
REQUEST_BODY=""
HEADERS=""

# Save data from last request here
declare -A request_details

while getopts "u:m:e:b:d:h:i:j:k:" arg
do

    case "${arg}" in
        u)
          # Base URL
          echo "URL: $OPTARG"
          FULL_URL="${OPTARG}"
          request_details["URL"]="${OPTARG}"
          ;;
        
        m)
          # Method 
          echo "Method: $OPTARG"
          CURL_CMD="${CURL_CMD} --request ${OPTARG}"
          request_details["METHOD"]="${OPTARG^^}"
          ;;
        e)
          # Endpoint
          echo "Endpoint: $OPTARG"
          FULL_URL="${FULL_URL}${OPTARG}"
          request_details["ENDPOINT"]="${OPTARG}"
          ;;
        b)
          # Bearer Token (JWT)  
          echo "Token: $OPTARG"
          HEADERS="${HEADERS} --header 'Authorization: Bearer ${OPTARG}'"
          request_details["TOKEN"]="${OPTARG}"
          ;;
        d)
          # Request Body
          echo "Request Body: $OPTARG"
          REQUEST_BODY="--data '${OPTARG}' --header 'Content-Type: application/json'"
          request_details["REQUEST_BODY"]="${OPTARG}"
          ;;
        h)
          # Headers
          echo "Header: $OPTARG"
          HEADERS="${HEADERS} --header '${OPTARG}'"
          request_details["HEADERS"]="${request_details["HEADERS"]} ${HEADERS}"
          ;;
        i)
          # Headers
          echo "Header: $OPTARG"
          HEADERS="${HEADERS}${OPTARG}"
          request_details["HEADERS"]="${request_details["HEADERS"]} ${HEADERS}"
          ;;
        j)
          # Headers
          echo "Header: $OPTARG"
          HEADERS="${HEADERS}${OPTARG}"
          request_details["HEADERS"]="${request_details["HEADERS"]} ${HEADERS}"
          ;;
        k)
          # Headers
          echo "Header: $OPTARG"
          HEADERS="${HEADERS}${OPTARG}"
          request_details["HEADERS"]="${request_details["HEADERS"]} ${HEADERS}"
          ;;
       \?)
          echo "[DEFAULT CASE] var: $var"
          ;;

    esac
done

# Proces request if any scripts args are passed in
if [[ ! -z "${request_details[URL]}" ]]; then
    
    # If no HTTP Method specified defaul to Get
    [[ -z "${request_details[METHOD]}" ]] && request_details["METHOD"]="GET" && CURL_CMD="${CURL_CMD} --request GET" 

    # eval "${CURL_CMD} '${FULL_URL}' ${HEADERS} ${REQUEST_BODY} | jq"
    new_result=$(eval "${CURL_CMD} '${request_details[URL]}${request_details[ENDPOINT]}' ${request_details[HEADERS]} ${request_details[REQUEST_BODY]}")

    contains_error=$(jq -r '.' <<< "${new_result}" 2>&1 | grep 'parse error' | wc -l)

    if [[ ${contains_error} -gt 0 ]]; then
        echo "${new_result}"
    else
        echo ${new_result} | jq
    fi
fi





while true
do

  # Read info for new request
  echo -e "\n\n======== New request ========\n\n"
 
  # Show any existing values we already have saved
  [[ ! -z "${request_details[URL]}" ]] && echo "URL: ${request_details[URL]}"
  [[ ! -z "${request_details[HEADERS]}" ]] && echo "Headers: ${request_details[HEADERS]}"
  [[ ! -z "${request_details[ENDPOINT]}" ]] && echo "Endpoint: ${request_details[ENDPOINT]}"


  # Make sure we require a URL
  if [[ -z "${request_details[URL]}" ]]; then
      read -p "URL: " new_url

      [[ -z "${new_url}" ]] && echo "A URL is required!" && continue
  fi
 
  endpoint_note=""
  [[ ! -z "${request_details[ENDPOINT]}" ]] && endpoint_note=" (leave blank to use previous)"
  read -p "Endpoint:$endpoint_note " new_endpoint
  read -p "HTTP Method: " new_method
  read -p "Request Body: " new_body
 
  [[ ! -z "${new_endpoint}" ]] && request_details["ENDPOINT"]=${new_endpoint}
  [[ ! -z "${new_method}" ]] && request_details["METHOD"]=${new_method^^}
  [[ ! -z "${new_body}" ]] && request_details["REQUEST_BODY"]="--data '${new_body}' --header 'Content-Type: application/json'"
  [[ ! -z "${new_url}" ]] && request_details["URL"]=${new_url}
 
  # Default to GET if nothing passed in
  [[ -z "${request_details[METHOD]}" ]] && request_details["METHOD"]="GET" && CURL_CMD="${CURL_CMD} --request GET" 
  
  new_result=$(eval "${CURL_CMD} '${request_details[URL]}${request_details[ENDPOINT]}' ${request_details[HEADERS]} ${request_details[REQUEST_BODY]}")
 
  contains_error=$(jq -r '.' <<< "${new_result}" 2>&1 | grep 'parse error' | wc -l)
  
  if [[ ${contains_error} -gt 0 ]]; then
      echo "${new_result}"
  else
      echo ${new_result} | jq
  fi

done

# FORMAT
#curl --silent --location --request POST '{JSON}' --header 'Authorization: Bearer {token} | jq
