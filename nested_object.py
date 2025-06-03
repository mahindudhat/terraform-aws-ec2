#!/usr/bin/env python3

def get_value_by_path(obj, path, delimiter="/"):
    keys = path.split(delimiter)
    current = obj

    for key in keys:
        if isinstance(current, dict) and key in current:
            current = current[key]
        else:
            return None  # key path is invalid
    return current
    
vehical_list = {"audi": {"benz": {"bmw": "car"}}}
vehical_type = "audi/benz/bmw"
print(get_value_by_path(vehical_list, vehical_type))

security = {"detect": {"respond": {"recover": "manage risk"}}}
mitigation = "detect/respond/recover"
print(get_value_by_path(security, mitigation))