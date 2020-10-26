from mongoengine import connect
from mongoengine import disconnect
from greenthumb import config

class MongoConnect:
    def __enter__(self):
        connect(config.MONGO_URI, alias='gt_mongo_conn')
    
    def __exit__(self):
        disconnect(alias='gt_mongo_conn')