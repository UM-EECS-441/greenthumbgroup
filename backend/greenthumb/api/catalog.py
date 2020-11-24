import greenthumb
import json
import flask

from greenthumb import util
import mongoengine
import bson


"""

GreenThumb REST API: plant catalog.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/catalog/', methods=['GET'])
def get_catalog():

    """ Route to get the catalog plant list """

    plants = []

    # connects to data db
    with util.MongoConnect():
        # Queries the catalog document for all plants
        # and returns all their information as json
        for plant in greenthumb.models.mongo.plant_types.objects():
            plants.append(plant.to_dict())

    

    return flask.jsonify(plants)

@greenthumb.app.route('/api/v1/catalog/<string:plant_id>/', methods=['GET'])
def get_catalog_plant_page(plant_id):

    """ Route to get a plant page from the catalog """

    # connects to data db
    with util.MongoConnect():

        # Queries catalog Document for plant with matching id
        plant = greenthumb.models.mongo.plant_types.objects.get(id=plant_id)

        # returns json of plant information
        return flask.jsonify(plant.to_dict_base64())
