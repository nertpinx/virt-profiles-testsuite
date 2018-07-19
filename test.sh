#!/bin/bash

_echo2()
{
    echo "$@" >&2
}

_err()
{
    _echo2 "$@"
    exit 1
}

_curl_opts()
{
    local method="$1"
    local request_file="$2"

    case "${method}" in
        GET)
            echo "-G -d $(paste -sd '&' "${request_file}")"
            ;;
        POST)
            echo "--data '$(cat "${request_file}")'"
            ;;
        *)
            ;;
    esac
}

_unify()
{
    local tool
    if which jq >/dev/null; then
        tool="jq -S ."
    elif which python3 >/dev/null; then
        tool="python3 -m json.tool --sort-keys"
    elif which python2 >/dev/null; then
        tool="python2 -m json.tool"
    else
        _err "No way to unify JSON structs"
    fi

    ${tool} "$@"
}

_test_case()
{
    local route="$1"
    local method="$2"
    local request_file="$3"
    local expected_code="$4"
    local response_file="$5"
    local test_name="$5"

    rm -rf .virt_tests_*
    local tmpdir="$(mktemp -d -p . .virt_tests_XXXXXXXX)"

    local def_opts="-s -S -q"
    local url="http://localhost:${PORT-12345}/${route}/"
    local var_opts="$(_curl_opts ${method} ${request_file})"
    local outs="-D ${tmpdir}/headers.txt -o ${tmpdir}/content.txt"
    local opts="${def_opts} ${outs} ${var_opts}"

    local curl_output
    curl_output=$(curl ${opts} "${url}" 2>&1)
    local curl_result="$?"
    if [[ "${curl_result}" != $? ]]; then
        _echo2 "Test case '${test_name}' failed:"
        _echo2 "  curl exited with error ${curl_result}:"
        _echo2 "    ${curl_output}"
        _echo2 "  Manual test command:"
        _echo2 "    curl ${opts} '${url}'"
        return 1
    fi

    local actual_code="$(head -n 1 "${tmpdir}/headers.txt" | cut -f2 -d' ')"

    if [[ "${expected_code}" != "${actual_code}" ]]; then
        _echo2 "Test case '${test_name}' failed:"
        _echo2 "  Expected response code: ${expected_code}"
        _echo2 "  Returned response code: ${actual_code}"
        _echo2 "  Manual test command:"
        _echo2 "    curl ${opts} -D /dev/stdout '${url}'"
        return 1
    fi

    if ! _unify "${tmpdir}/content.txt" >"${tmpdir}/response_unified.txt"; then
        _echo2 "Test '${test_name}' failed:"
        _echo2 "  Output was possibly invalid JSON"
        _echo2 "  See content in: ${tmpdir}"
        return 1
    fi

    if ! _unify "${response_file}" >"${tmpdir}/expected_unified.txt"; then
        _err "Possibly invalid JSON in ${response_file}, fix the tests!"
    fi

    if ! diff -u "${tmpdir}/response_unified.txt" "${tmpdir}/expected_unified.txt" >&2; then
        _echo2 "Test '${test_name}' failed:"
        _echo2 "  Output in: ${tmpdir}"
        _echo2 "  Manual test command:"
        _echo2 "    curl ${opts} '${url}'"
        return 1
    fi

    rm -f "${tmpdir}"/{headers,content,{response,expected}_unified}.txt
    rmdir "${tmpdir}"

    return 0
}

_test_route_method()
{
    local case_num
    local route="$1"
    local method="$2"
    local sub="routes/${route}/_${method}/"
    local result=0

    for case_num in {000..999}; do
        local files=( ${sub}${case_num}_request*.json )
        if [[ ${#files[@]} != 1 || ! -r "${files[0]}" ]]; then
            break
        fi
        local request_file="${files[0]}"

        local files=( ${sub}${case_num}_response_*.json )
        if [[ ${#files[@]} != 1 || ! -r "${files[0]}" ]]; then
            break
        fi
        local response_file="${files[0]}"

        local response_code="${response_file#${sub}${case_num}_response_}"
        response_code="${response_code%.json}"

        local test_name="${request_file%.json}"
        test_name="${test_name/_request_/: }"

        if ! _test_case "${route}" "${method}" "${request_file}" \
             "${response_code}" "${response_file}" "${test_name}"; then
            result=1
        fi
    done

    return ${result}
}

_test_route()
{
    local method
    local route="$1"
    local sub="routes/$route/_"
    local result=0

    for method in ${sub}*; do
        if ! _test_route_method "$route" "${method#${sub}}"; then
            result=1
        fi
    done

    return $result
}

_main()
{
    local route
    local sub="routes/"
    local result=0

    for route in ${sub}*; do
        if ! _test_route "${route#${sub}}"; then
            result=1
        fi
    done

    return $result
}

if _main; then
    echo All tests passed
else
    echo Some tests failed, see stderr
fi
