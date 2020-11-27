"""

GreenThumb task models.

GreenThumb Group <greenthumb441@umich.edu>

"""

class WateringTask:
    def __init__(self, plant_name, plant_type, plant_lat, plant_long, water_instr):
        self.plant_name = plant_name
        self.plant_type = plant_type
        self.plant_lat = plant_lat
        self.plant_long = plant_long
        self.water_instr = water_instr

class ColdWeatherTask:
    def __init__(self, plant_name, plant_type, plant_lat, plant_long, plant_zone):
        self.plant_name = plant_name
        self.plant_type = plant_type
        self.plant_lat = plant_lat
        self.plant_long = plant_long
        self.plant_zone = plant_zone


