from mongoengine import Document
from mongoengine import (ListField, StringField, IntField, MapField, FloatField, DateField)

class users(Document):
    email = StringField()
    gardens = ListField()

class plant_types(Document):
    '''
    Document of plants catalog:
    name = common name of the plant
    species = scientific name of the plant
    tags = a Map of plant_tag name :
     list of tag value string
    description = String containing description of plant
    //TODO: plant_image = image of each plant
    //TODO: guides = link to guides that might be useful
    '''

    name = StringField()
    species = StringField()
    tags = MapField(ListField(StringField()))
    description = StringField()
    days_to_water = IntField()
    watering_description = StringField()

class gardens(Document):
    name = StringField()
    address = StringField()
    topleft_lat = FloatField()
    topleft_long = FloatField()
    bottomright_lat = FloatField()
    bottomright_long = FloatField()
    plants = ListField()

class user_plants(Document):
    latitude = FloatField()
    longitude = FloatField()
    light_level = IntField()
    last_watered = DateField()

class guides(Document):
    title = StringField()
    text = StringField()
    references = StringField()