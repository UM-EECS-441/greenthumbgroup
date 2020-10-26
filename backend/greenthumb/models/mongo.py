from greenthumb.api import catalog
from mongoengine import Document, StringField, ListField, MapField

class catalog(Document):
    '''
    Document of plants catalog:
    plant_name = common name of the plant
    plant_species = scientific name of the plant
    plant_tags = a Map of plant_tag name :
     list of tag value string
    plant_description = String containing description of plant
    //TODO: plant_image = image of each plant
    //TODO: guides = link to guides that might be useful
    '''
    plant_name = StringField()
    plant_species = StringField()
    plant_tags = MapField(ListField(StringField()))
    plant_description = StringField()

class guides(Document):
    title = StringField()
    text = StringField()
    references = StringField()