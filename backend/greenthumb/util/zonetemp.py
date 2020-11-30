# zone temp map in celsius, max bias
"""

GreenThumb utils: zone to temperature mapping.

GreenThumb Group <greenthumb441@umich.edu>

"""

# From the USDA
ZONE_TEMP_MAP = {
    "0": -51.1,
    "1": -45.6,
    "2": -40,
    "3": -34.4,
    "4": -28.9,
    "5": -23.3,
    "6": -17.8,
    "7": -12.2,
    "8": -6.7,
    "9": -1.1,
    "10": 4.4,
    "11": 10,
    "12": 15.6,
    "13": 21.1
}

def zone_min_temp(zone):

    """

    Convert zone number to a minimum temperature that a plant can handle.

    """

    if int(zone) > 13 or int(zone) < 1:
        return None

    return ZONE_TEMP_MAP[str(zone)]
