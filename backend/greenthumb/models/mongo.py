import mongoengine

class guides(mongoengine.Document):
    title = mongoengine.StringField()
    text = mongoengine.StringField()
    references = mongoengine.StringField()