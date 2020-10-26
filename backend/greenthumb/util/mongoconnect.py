from mongoengine import connect
from mongoengine import disconnect
from greenthumb import config

class MongoConnect:
    def __enter__(self):
        connect(config.MONGO_URI, alias='default')
    
    def __exit__(self):
        disconnect(alias='default')