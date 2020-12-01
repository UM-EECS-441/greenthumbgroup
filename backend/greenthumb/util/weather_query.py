from greenthumb import config
import requests
import os
from datetime import datetime, date, time
from time import mktime
import json
import math

from pytz import timezone, utc
from timezonefinder import TimezoneFinder

from greenthumb.models.mongo import users, gardens, plant_types, user_plants
import mongoengine
from mongoengine.queryset.visitor import Q
from greenthumb.util import MongoConnect









def get_offset(lat, lng):
    """
    returns a location's time zone offset from UTC in seconds.
    """
    tzf = TimezoneFinder()
    today = datetime.now()
    try:
        tz_target = timezone(tzf.timezone_at(lng=lng, lat=lat))
        # ATTENTION: tz_target could be None! handle error case
    except:
        return 0
    today_target = tz_target.localize(today)
    today_utc = utc.localize(today)
    return (today_utc - today_target).total_seconds()

def get_historical_data(lat, lng, today_midnight_utc):
    """
    Returns an array of dict's containing the min temp, max temp,
    mm of rain, and mm of snow, for past 5 days before today
    """

    OWM_KEY = ""
    
    with open(config.OWM_KEY_FILE, 'r') as owmkey_file:
        OWM_KEY = str(owmkey_file.readline()).strip()

    ONE_HIST_URL = "https://api.openweathermap.org/data/2.5/onecall/timemachine"
    units = "metric"


    hist_data = []
    for i in range(5):
        # Get request payload
        payload = {"lat":lat, "lon":lng, "dt": str(today_midnight_utc - 1*86400).split(".")[0], "appid": OWM_KEY, "units": units}
        # Gets the historic open weather map api url for i days in the past
        # (from 0 offset being yesterday to 5 days in the past)
        # Converts json to dict
        resp = requests.get(ONE_HIST_URL, params=payload)
        if resp.ok:

            hist_json = json.loads(resp.text)

            # Min temp in celcius
            min_temp = 100
            # Max temp in celscius
            max_temp = -100
            # rain in mm
            rain = 0
            # snow in mm
            snow = 0
            for h_data in hist_json["hourly"]:
                if (h_data['temp'] > max_temp):
                    max_temp = h_data["temp"]
                if (h_data["temp"] < min_temp):
                    min_temp = h_data["temp"]
                if (h_data.get("rain") != None):
                    rain += h_data["rain"]["1h"]
                if (h_data.get("snow") != None):
                    snow += h_data["snow"]["1h"]

            # print(json.dumps(hist_json))
            hist_data.append({"dt": hist_json["current"]["dt"], "min_temp": min_temp, "max_temp": max_temp, "rain": rain, "snow": snow})
        else:
            hist_data.append({})
    return hist_data

def get_forecast_data(lat, lng):
    """
    Returns an array of dict's containing the min temp, max temp,
    mm of rain, and mm of snow, for next 5 days, including today
    """

    OWM_KEY = ""

    with open(config.OWM_KEY_FILE, 'r') as owmkey_file:
        OWM_KEY = str(owmkey_file.readline()).strip()

    ONE_FORE_URL = "https://api.openweathermap.org/data/2.5/onecall"
    exclude = "minutely,hoursly,alerts"
    units = "metric"

    forecast_data = []
    # Get request payload
    payload = {"lat":lat, "lon":lng, "exclude": exclude, "appid": OWM_KEY, "units": units}
    # Gets the historic open weather map api url for next 7 days
    # (from 0 offset being today to 7 days in the future)
    # Converts json to dict
    resp = requests.get(ONE_FORE_URL, params=payload)

    if resp.ok:

        forecast_json = json.loads(resp.text)
        for i in range(5):
            

            h_data = forecast_json["daily"][i]
                
            rain = 0
            snow = 0
            if (h_data.get("rain") != None):
                rain += h_data["rain"]
            if (h_data.get("snow") != None):
                snow += h_data["snow"]

            # print(json.dumps(hist_json))
            forecast_data.append({"dt": (h_data["dt"] // 86400) * 86400,
                "min_temp": h_data["temp"]["min"],
                "max_temp": h_data["temp"]["max"], 
                "rain": rain, "snow": snow})
    else:
        forecast_data.append({})

    return forecast_data

def calc_garden_plants_watering(garden_id):
    '''
    Given user garden id, acquires weather
    predicted and historical data for that garden.
    Then calculates if the weather watered each plant
    enough
    '''
    # Connects to the data database
    with MongoConnect():

        # Gets the user's garden
        user_garden = gardens.objects(id=garden_id)[0]
        lat_avg = 0
        long_avg = 0

        # Calculates average latitude/longitude of garden
        lat_avg += user_garden["topleft_lat"]
        lat_avg += user_garden["bottomright_lat"]
        lat_avg /= 2

        long_avg += user_garden["topleft_long"]
        long_avg += user_garden["bottomright_long"]
        long_avg /= 2

        # Gets offset from UTC
        utc_offset = get_offset(lat_avg, long_avg)
        # Gets midnight local in UTC
        # tzf = TimezoneFinder()
        # tz = timezone(tzf.certain_timezone_at(lng=long_avg, lat=lat_avg))
        today_date = date.today()
        today_midnight_utc = datetime.combine(today_date, time(0,0))
        # UTC Today at midnight in epoch time
        today_midnight_epoch_utc = mktime(today_midnight_utc.timetuple()) + utc_offset

        # Gets last 5 days historical data
        # by filtering out rain, snow, and min/max temp's
        hist_data = get_historical_data(lat_avg, long_avg, today_midnight_epoch_utc)
        # Gets next 5 days forecast (today + 4 days in future) daily data
        # by filtering out rain, snow, and min/max temps
        forecast_data = get_forecast_data(lat_avg, long_avg)

        # Iterates through each plant in the user's garden
        # And adds it to a dictionary stating if the weather watered the plant sufficiently
        plant_watering_data = []
        for plant_id in user_garden.plants:
            plant = user_plants.objects(id=plant_id)[0]
            if plant.outdoors:
                plant_type = plant_types.objects(id=plant.plant_type_id)[0]
                rain_amt = 0
                last_day_watered = -1
                # Uses the min because we can only look back 5 days in the past
                # so max size of historical data array is size 5 (max index = 4)
                if "days_to_water" in plant_type:
                    for i in range(min(plant_type["days_to_water"] - 1, 4), -1, -1):
                        rain_amt += hist_data[i]["rain"]
                        if hist_data[i]["rain"] > 0:
                            last_day_watered = i + 1

                    # Appends that plant's rain amount to the plant_weather_data
                    plant_watering_data.append({"plant_id": str(plant_id), "rain_amt": rain_amt, "last_watered": None})

                    # If sufficiently watered then set last watered day
                    # to last day it rained
                    if rain_amt > 40 - 5*plant_type["days_to_water"]:
                        plant_watering_data[-1]["last_watered"] = datetime.fromtimestamp(today_midnight_epoch_utc - last_day_watered * 86400)
                        plant.last_watered = datetime.fromtimestamp(today_midnight_epoch_utc - last_day_watered * 86400)

    # Returns a dictionary of historical, forecast, and plant watering data
    return {"hist_data": hist_data, "forecast_data": forecast_data, "plant_watering_data": plant_watering_data}
