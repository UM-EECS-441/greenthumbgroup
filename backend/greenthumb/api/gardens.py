import greenthumb
import flask
import json

from greenthumb import util

"""

GreenThumb REST API: gardens.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/usergarden/<string:user_id>/add_garden_location', methods=['POST'])
def add_garden(user_id):
    expected = ['name', 'address', 'latitudetl', 'longitudetl', 'latitudebr, longitudebr']

    with util.MongoConnect():
        # if user not in database 403
        if greenthumb.models.mongo.users.objects(email=user_id) == []:
            return 403

        # check that the right info was provided, else 401
        for field in expected:
            if field not in flask.request.json:
                return 401

        body = flask.request.json
        # add garden to db
        greenthumb.models.mongo.gardens(name=body['name'], address=body['address'], topleft_lat=body['latitudetl'],
                                        topleft_long=body['longitudetl'], bottomright_lat=body['latitudebr'], bottomright_long=body['longitudebr']).save()

    return 200