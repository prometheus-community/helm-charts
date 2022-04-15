#!/bin/bash

# Kubernetes versions to test (exactly 5 must be listed here!)
k8s_versions="1.19 1.20 1.21 1.22 1.23"

#tag="$1"
#chart="$(echo "${tag}" | sed -r 's|-[0-9]+.[0-9]+.[0-9]+$||g')"
chart="kube-prometheus-stack"

# Check if the chart folder exists
if [[ ! -d charts/$chart ]] ; then 
    echo "error: folder charts/$chart doesn't exists!"
    exit 1
fi

create_matrix()
{
    # Create matrix header with Kubernetes versions
    matrix_result="| **Chart Version** |"
    for k8s_version in ${k8s_versions}
    do
        matrix_result+=" **Kubernetes ${k8s_version}** |"
    done

    matrix_result+="\n|-------------------|:-------------------:|:-------------------:|:-------------------:|:-------------------:|:-------------------:|"

    # Get the 5 latest chart versions (vX.X.0)
    chart_versions="$(gh release list -R prometheus-community/helm-charts -L 300 | grep -E -m 5 "${chart}"-[0-9]+.[0-9]+.0 | awk '{ print $1 }' | sed "s|${chart}-||g" | sort -urV)"

    cd "charts/${chart}" || exit

    for chart_version in ${chart_versions}
    do
        # Checkout tag version
        git checkout ${chart}-${chart_version}

        # Create a new matrix line
        matrix_line="| **v${chart_version}+**       |"

        for k8s_version in ${k8s_versions}
        do
            # Test Kubernetes versions
            missing_apis="$(helm template . | kubepug --input-file - --api-walk --k8s-version "v${k8s_version}.0" --format json | jq '.DeletedAPIs | length')"
            deprecated_apis="$(helm template . | kubepug --input-file - --api-walk --k8s-version "v${k8s_version}.0" --format json | jq '.DeprecatedAPIs | length')"

            # Append matrix line depending on result
            if [[ ${missing_apis} != "0" ]] ; then
                matrix_line+="         ⛔️          |"
            elif [[ ${deprecated_apis} != "0" ]] ; then
                matrix_line+="         ☑️          |"
            else
                matrix_line+="         ✅          |"
            fi
        done

        matrix_result+="\n${matrix_line}"
    done

    # print matrix to stdout
    echo -e "${matrix_result}"

    # Checkout main to write matrix
    git checkout main

    # Oneliner to insert the matrix in README.md
    # Source: https://stackoverflow.com/questions/1030787/multiline-search-replace-with-perl
    perl -i -pe "BEGIN{undef \$/;} s/<\!-- START COMPATIBILITY MATRIX -->.*<\!-- END COMPATIBILITY MATRIX -->/<\!-- START COMPATIBILITY MATRIX -->\n$(echo -e "${matrix_result}")\n<\!-- END COMPATIBILITY MATRIX -->/smg" README.md
}

create_matrix