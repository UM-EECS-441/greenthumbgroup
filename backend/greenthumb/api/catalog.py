import greenthumb
import json
import mongoengine
import flask


"""

GreenThumb REST API: plant catalog.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/catalog/', methods=['GET'])
def get_catalog():

    """ Route to get the catalog plant list """

    # connects to data db
    mongoengine.connect('data')

    # Queries the catalog document for all plants
    # and returns all their information as json
    plants = []
    for plant in greenthumb.models.mongo.catalog.objects():
        plant.append(json.loads(plant.to_json()))

    return flask.jsonify(plants)

@greenthumb.app.route('/api/v1/catalog/<str:plant_id>/', methods=['GET'])
def get_catalog_plant_page(plant_id):

    """ Route to get a plant page from the catalog """

    # connects to data db
    mongoengine.connect('data')

    # Queries catalog Document for plant with matching id
    plant = greenthumb.models.mongo.catalog.objects(id=plant_id)

    # json.loads(plant.to_json())

    # returns json of plant information
    return flask.jsonify(plant)
