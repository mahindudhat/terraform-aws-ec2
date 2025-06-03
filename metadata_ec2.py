#!/usr/bin/env python3

import requests
import json
import sys

BASE_URL = "http://10.0.2.31/latest/meta-data/"

def get_metadata(url):
    result = {}
    try:
        response = requests.get(url, timeout=2)
        response.raise_for_status()
    except Exception as e:
        return f"Error accessing {url}: {str(e)}"

    for line in response.text.strip().split('\n'):
        full_url = url + line
        if line.endswith("/"):
            result[line.rstrip("/")] = get_metadata(full_url + "/")
        else:
            try:
                value = requests.get(full_url, timeout=2).text
                result[line] = value
            except Exception as e:
                result[line] = f"Error fetching {line}: {str(e)}"
    return result

def get_single_metadata_key(key_path):
    key_url = BASE_URL + key_path
    try:
        response = requests.get(key_url, timeout=2)
        response.raise_for_status()
        return response.text
    except Exception as e:
        return f"Error fetching key '{key_path}': {str(e)}"

if __name__ == "__main__":
    if len(sys.argv) == 2:
        key = sys.argv[1]
        print(json.dumps({key: get_single_metadata_key(key)}, indent=4))
    else:
        print(json.dumps(get_metadata(BASE_URL), indent=4))
