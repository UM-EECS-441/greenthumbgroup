import mongoengine
from mongoengine.fields import ListField, LongField

class users(mongoengine.Document):
    email = mongoengine.StringField()
    gardens = ListField()

class plant_types(mongoengine.Document):
    name = mongoengine.StringField()
    species = mongoengine.StringField()
    description = mongoengine.StringField()
    days_to_water = mongoengine.IntField()
    watering_description = mongoengine.StringField()

class gardens(mongoengine.Document):
    topleft_lat = mongoengine.FloatField()
    topleft_long = mongoengine.FloatField()
    bottomright_lat = mongoengine.FloatField()
    bottomright_long = mongoengine.FloatField()
    plants = mongoengine.ListField()

class user_plants(mongoengine.Document):
    latitude = mongoengine.FloatField()
    longitude = mongoengine.FloatField()
    light_level = mongoengine.IntField()
    last_watered = mongoengine.DateField()

class guides(mongoengine.Document):
    title = mongoengine.StringField()
    text = mongoengine.StringField()
    references = mongoengine.StringField()