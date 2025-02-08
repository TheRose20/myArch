#!/bin/bash

download_images() {
    local input_file="$1"
    local output_dir="${2:-.}"

    if [[ ! -f "$input_file" ]]; then
        echo "File $input_file not exist"
        return 1
    fi

    mkdir -p "$output_dir"

    while IFS= read -r line; do
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        url=$(echo "$line" | awk '{print $1}')
        filename=$(echo "$line" | awk '{print $2}')

        if [[ -z "$filename" ]]; then
            filename=$(basename "$url")
        fi

        full_path="$output_dir/$filename"

        echo "Download $url to $full_path"
        curl -o "$full_path" "$url"

    done < "$input_file"
}

download_images "image_links.txt" "/home/user/picture/wallpaper"
