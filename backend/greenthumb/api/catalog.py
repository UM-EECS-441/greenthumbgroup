import greenthumb
import json
import mongoengine


"""

GreenThumb REST API: plant catalog.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/catalog/', methods=['GET'])
def get_catalog():

    """ Route to get the catalog plant list """

    # TODO: Implement, figure out how to do it by page number.

    pass

@greenthumb.app.route('/api/v1/catalog/<int:plant_id>/', methods=['GET'])
def get_catalog_plant_page(plant_id: int):

    """ Route to get a plant page from the catalog """

    # TODO: Implement.

    # connects to data db
    mongoengine.connect('data')

    # Queries plant Document for plant with matching id
    plant = greenthumb.models.mongo.plants.objects(id=plant_id)

    # json.loads(plant.to_json())

    return flask.jsonify(plant)

    for guide in greenthumb.models.mongo.guides.objects():
        guides.append(json.loads(guide.to_json()))

    return flask.jsonify(guides)

    pass