#!/bin/bash

_main()
{
    local path
    local i
    local files

    for path in routes/*/*/; do
        for i in {000..999}; do
            files=( ${path}${i}_response_*.json )
            if [[ ${#files[@]} != 1 || ! -r "${files[0]}" ]]; then
                break
            fi

            local response_code="${files[0]#*/${i}_response_}"
            response_code="${response_code%.json}"

            data="$(cat "${files[0]}")"

            nc -l -p ${PORT-12345} <<EOF
HTTP/1.1 ${response_code} OK
Content-type: application/json
Content-Length: $((${#data}+1))

${data}
EOF
            # Don't break lines
            echo
        done
     done
}

_main
