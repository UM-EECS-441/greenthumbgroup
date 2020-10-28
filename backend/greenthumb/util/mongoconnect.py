from mongoengine import connect
from mongoengine import disconnect
from greenthumb import config

"""

GreenThumb utils: Mongo DB connection.

GreenThumb Group <greenthumb441@umich.edu>

"""

class MongoConnect:
    '''
    Used in a similar way to opening files:

    with MongoConnect():
        your_code_here
    
    '''

    def __enter__(self):
        connect(config.MONGO_URI, alias='default')
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        disconnect(alias='default')