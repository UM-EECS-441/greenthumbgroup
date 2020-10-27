import greenthumb
import json

from greenthumb import util
from greenthumb.models.mongo import (users, gardens)
from flask import (abort, request, session, jsonify)

"""

GreenThumb REST API: usergarden.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('api/v1/usergarden/', methods=['GET'])
def get_user_gardens():

    if 'email' not in session:
        abort(403)

    user_gardens = []

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if user == []:
            abort(401)
        user = user[0]
        for garden_id in user.gardens:
            garden = gardens.objects(_id = garden_id)
            if garden != []:
                garden = garden[0]
                user_gardens.append(json.loads(garden.to_json()))

    return jsonify(user_gardens)

@greenthumb.app.route('api/v1/usergarden/<int:garden_id>', methods=['GET'])
def get_garden(garden_id: int):

    if 'email' not in session:
        abort(403)

    garden = {}

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if user == []:
            abort(401)
        user = user[0]
        if garden_id in user.gardens:
            garden = gardens.objects(_id = garden_id)
            if garden != []:
                garden = json.loads(garden[0].to_json())

    return jsonify(garden)

@greenthumb.app.route('/api/v1/usergarden/add_garden_location', methods=['POST'])
def add_garden():
    expected = ['name', 'address', 'latitudetl', 'longitudetl', 'latitudebr, longitudebr']

    if 'email' not in session:
        abort(403)

    # check that the right info was provided, else 401
    for field in expected:
            if field not in request.json:
                abort(401)

    with util.MongoConnect():
        # if user not in database 401
        user = greenthumb.models.mongo.users.objects(email=session['email'])
        if user == []:
            abort(401)
        user = user[0]

        body = request.json
        # add garden to db
        garden = greenthumb.models.mongo.gardens(name=body['name'], address=body['address'], topleft_lat=body['latitudetl'],
                                        topleft_long=body['longitudetl'], bottomright_lat=body['latitudebr'], bottomright_long=body['longitudebr'])
        garden.save()

        # add garden id to user's garden list
        user.gardens.append(garden.id)
        user.save()

    return 200
