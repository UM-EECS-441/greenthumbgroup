import greenthumb
import json

from greenthumb import util
from greenthumb.models.mongo import (users, gardens, plant_types, user_plants)
from flask import (abort, request, session, jsonify)

"""

GreenThumb REST API: usergarden.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/usergarden/', methods=['GET'])
def get_user_gardens():

    '''
    Route which returns a list of all gardens in json format
    '''

    if 'email' not in session:
        abort(403)

    user_gardens = []

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if user == []:
            abort(401)
        user = user[0]
        for garden_id in user.gardens:
            garden = gardens.objects(_id=garden_id)
            if garden != []:
                garden = garden[0]
                user_gardens.append(json.loads(garden.to_json()))

    return jsonify(user_gardens)

@greenthumb.app.route('/api/v1/usergarden/<int:garden_id>/', methods=['GET'])
def get_garden(garden_id: int):

    '''
    Route which returns a json object with a single garden
    '''

    if 'email' not in session:
        abort(403)

    garden = {}

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if user == []:
            abort(401)
        user = user[0]
        if garden_id in user.gardens:
            garden = gardens.objects(_id=garden_id)
            if garden == []:
                abort(404)

            garden = json.loads(garden[0].to_json())

    return jsonify(garden)

@greenthumb.app.route('/api/v1/usergarden/add_garden/', methods=['POST'])
def add_garden_location():
    expected_fields = ['name', 'address', 'latitudetl', 'longitudetl', 'latitudebr, longitudebr']

    if 'email' not in session:
        abort(403)

    # check that the right info was provided, else 401
    for field in expected_fields:
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
                                        topleft_long=body['longitudetl'], bottomright_lat=body['latitudebr'], bottomright_long=body['longitudebr'], plants=[])
        garden.save()

        # add garden id to user's garden list
        user.gardens.append(garden.id)
        user.save()

    return 200


@greenthumb.app.route('/api/v1/usergarden/<int:garden_id>/add_plant/', methods=['POST'])
def add_plant_to_garden(garden_id: int):

    expected_fields = ['plant_type_id', 'latitude', 'longitude', 'light_level', 'last_watered']

    if 'email' not in session:
        abort(403)

    # check that the right info was provided, else 401
    for field in expected_fields:
        if field not in request.json:
            abort(401)
    
    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if user == []:
            abort(401)
        user = user[0]
        if garden_id in user.gardens:
            garden = gardens.objects(_id=garden_id)
            if garden == []:
                abort(401)
            garden = garden[0]
            if plant_types.objects(_id=request.json['plant_type_id']) == []:
                abort(401)
            if (request.json['latitude'] < garden['topleft_lat'] or
                request.json['latitude'] > garden['bottomright_lat'] or
                request.json['longitude'] < garden['topleft_long'] or
                request.json['longitude'] > garden['bottomright_long']):
                abort(401)

            user_plant = user_plants(plant_type_id=request.json['plant_type_id'],
                latitude=request.json['latitude'],
                longitude=request.json['longitude'],
                light_level=request.json['light_level'],
                last_watered=request.json['last_watered']).save()
            
            garden.plants.append(user_plant.id)
            garden.save()

            # TODO: do the notification stuff for watering here

@greenthumb.app.route('/api/v1/usergarden/<int:garden_id>/edit_plant/<int:plant_id>', methods=['PUT'])
def edit_plant_in_garden(garden_id: int, plant_id: int):

    expected_fields = ['plant_type_id', 'latitude', 'longitude', 'light_level', 'last_watered']

     if 'email' not in session:
        abort(403)

    # check that the right info was provided, else 401
    for field in expected_fields:
        if field not in request.json:
            abort(401)

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if user == []:
            abort(401)
        user = user[0]
        if garden_id in user.gardens:
            garden = gardens.objects(_id=garden_id)
            if garden == []:
                abort(401)
            garden = garden[0]
            if plant_id not in garden.plants:
                abort(401)
            if plant_types.objects(_id=request.json['plant_type_id']) == []:
                abort(401)
            if (request.json['latitude'] < garden['topleft_lat'] or
                request.json['latitude'] > garden['bottomright_lat'] or
                request.json['longitude'] < garden['topleft_long'] or
                request.json['longitude'] > garden['bottomright_long']):
                abort(401)

            plant = user_plants.objects(_id=plant_id)
            if plant = []:
                abort(401)
            plant = plant[0]

            plant.plant_type_id = request.json['plant_type_id']
            plant.latitude = request.json['latitude'],
            plant.longitude = request.json['longitude'],
            plant.light_level = request.json['light_level'],
            plant.last_watered = request.json['last_watered']
            plant.save()

        else:
            abort(401)

    return 200

@greenthumb.app.route('/api/v1/usergarden/<int:garden_id>/delete_plant/<int:plant_id>', methods=['DELETE'])
def delete_plant_in_garden(garden_id: int, plant_id: int):

     if 'email' not in session:
        abort(403)

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if user == []:
            abort(401)
        user = user[0]
        if garden_id in user.gardens:
            garden = gardens.objects(_id=garden_id)
            if garden == []:
                abort(401)
            garden = garden[0]
            if plant_id not in garden.plants:
                abort(401)

            plant = user_plants.objects(_id=plant_id)
            if plant = []:
                abort(401)
            plant = plant[0]

            garden.plants.remove(plant_id)
            garden.save()
            plant.delete()

        else:
            abort(401)

    return 200
