import greenthumb
import json
import sched

from greenthumb import util
from greenthumb.models.mongo import (users, gardens, plant_types, user_plants)
from flask import (abort, request, session, jsonify)

import datetime

import bson

"""

GreenThumb REST API: usergarden.

GreenThumb Group <greenthumb441@umich.edu>

"""
WATERING_DESCRIPTION = 'Water it.'

def is_valid_id(object_id):
    try:
        bson.objectid.ObjectId(object_id)
    except Exception as e:
        return False
    return True
    

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
        if str(user) == '[]':
            abort(401)
        user = user[0]
        for garden_id in user.gardens:
            garden = gardens.objects(id=garden_id)
            if garden != []:
                garden = garden[0]
                user_gardens.append(json.loads(garden.to_json()))

    return jsonify(user_gardens), 200


@greenthumb.app.route('/api/v1/usergarden/<string:garden_id>/', methods=['GET', 'PUT', 'DELETE'])
def get_garden(garden_id: str):
    '''
    Route which returns a json object with a single garden
    '''

    if 'email' not in session:
        abort(403)

    if not is_valid_id(garden_id):
        abort(401)

    if request.method == 'DELETE':
        with util.MongoConnect():
            user = users.objects(email=session['email'])
            if str(user) == '[]':
                abort(401)
            user = user[0]
            # need to do str(i) because user.gardens is a list of ObjectIdFields
            if garden_id in [str(i) for i in user.gardens]:
                try:
                    garden = gardens.objects(id=garden_id)
                except Exception as e:
                    abort(404)
                if str(garden) == '[]':
                    abort(404)
                
                garden = garden[0]
                user.gardens.remove(garden.id)

                # delete all plants in the garden
                for plant_id in garden.plants:
                    plant = user_plants.objects(id=plant_id)
                    if str(plant) == '[]':
                        continue
                    plant = plant[0]
                    plant_type = plant_types.objects(id=plant.plant_type_id)
                    if str(plant_type) == '[]':
                        plant.delete()
                        continue
                    plant_type = plant_type[0]

                    plant.delete()

                garden.delete()
                user.save()
            else:
                abort(401)
    elif request.method == 'PUT':
        expected_fields = ['name', 'address', 'latitudetl', 'longitudetl', 'latitudebr', 'longitudebr']
        for field in expected_fields:
            if field not in request.json:
                abort(401)

        with util.MongoConnect():
            user = users.objects(email=session['email'])
            if str(user) == '[]':
                abort(401)
            user = user[0]
            # need to do str(i) because user.gardens is a list of ObjectIdFields
            if garden_id in [str(i) for i in user.gardens]:
                garden = gardens.objects(id=garden_id)
                if str(garden) == '[]':
                    abort(404)
                garden = garden[0]
                garden.name = request.json['name']
                garden.address = request.json['address']
                garden.topleft_lat = request.json['latitudetl']
                garden.topleft_long = request.json['longitudetl']
                garden.bottomright_lat = request.json['latitudebr']
                garden.bottomright_long = request.json['longitudebr']
                garden.save()
            else:
                abort(401)
    else:
        garden = {}

        with util.MongoConnect():
            user = users.objects(email=session['email'])
            if str(user) == '[]':
                abort(401)
            user = user[0]
            if garden_id in [str(i) for i in user.gardens]:
                garden = gardens.objects(id=garden_id)
                if str(garden) == '[]':
                    abort(404)

                garden = json.loads(garden[0].to_json())

        return jsonify(garden)
    return "", 200

@greenthumb.app.route('/api/v1/usergarden/get_plants/', methods=['GET'])
def get_user_plants():
    '''
    Route which returns a list of all of the user's plants in json format
    '''

    if 'email' not in session:
        abort(403)

    plants_list = []

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if str(user) == '[]':
            abort(401)
        user = user[0]
        # add all plants in each of the user's gardens
        for garden_id in user.gardens:
            garden = gardens.objects(id=garden_id)
            if garden != []:
                garden = garden[0]
                for plant_id in garden.plants:
                    plant = user_plants.objects(id=plant_id)
                    if plant != []:
                        plant = plant[0]
                        plants_list.append(plant.to_dict())
                

    return jsonify(plants_list), 200

@greenthumb.app.route('/api/v1/usergarden/get_plants/<string:plant_id>/', methods=['GET'])
def get_user_plants_with_id(plant_id):
    '''
    Route which returns a the specified plant in json format
    '''

    if 'email' not in session:
        abort(403)

    if not is_valid_id(plant_id):
        abort(401)

    plants_list = {}

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if str(user) == '[]':
            abort(401)
        user = user[0]
        # add all plants in each of the user's gardens
        for garden_id in user.gardens:
            garden = gardens.objects(id=garden_id)
            if garden != []:
                garden = garden[0]
                for user_plant_id in garden.plants:
                    if plant_id != str(user_plant_id):
                        continue
                    try:
                        plant = user_plants.objects(id=plant_id)
                    except Exception as e:
                        abort(404)
                    if str(plant) == '[]':
                        abort(404)
                    plant = plant[0]
                    plants_list = plant.to_dict()
                

    return jsonify(plants_list), 200

@greenthumb.app.route('/api/v1/usergarden/add_garden/', methods=['POST'])
def add_garden_location():
    expected_fields = ['name', 'address', 'latitudetl',
        'longitudetl', 'latitudebr', 'longitudebr']

    if 'email' not in session:
        abort(403)

    # check that the right info was provided, else 401
    for field in expected_fields:
        if field not in request.json:
            abort(401)

    with util.MongoConnect():
        # if user not in database 401
        user = greenthumb.models.mongo.users.objects(email=session['email'])
        if str(user) == '[]':
            abort(401)
        user = user[0]

        body = request.json
        # add garden to db
        garden = greenthumb.models.mongo.gardens(name=body['name'], address=body['address'], topleft_lat=body['latitudetl'],
                                        topleft_long=body['longitudetl'], bottomright_lat=body['latitudebr'], bottomright_long=body['longitudebr'], plants=[])
        garden.save()

        # add garden id to user's garden list
        user.gardens.append(str(garden.id))
        user.save()
        return {"id": str(garden.id)}, 200

@greenthumb.app.route('/api/v1/usergarden/<string:garden_id>/add_plant/', methods=['POST'])
def add_plant_to_garden(garden_id: str):

    expected_fields = ['plant_type_id', 'latitude',
        'longitude', 'light_duration', 'light_intensity', 'last_watered', 'name', 'price', 'outdoors']

    if 'email' not in session:
        abort(403)

    if not is_valid_id(garden_id):
        abort(401)

    # check that the right info was provided, else 401
    for field in expected_fields:
        if field not in request.json:
            # Don't reject if still using the old set of expected fields
            if field in ['light_duration', 'light_intensity', 'price']:
                request.json[field] = 0
            elif field == 'name':
                request.json['name'] = ''
            elif field == 'outdoors':
                request.json['outdoors'] = True
            else:
                abort(401)

    if not is_valid_id(request.json['plant_type_id']):
        abort(401)

    if request.json['last_watered'].find('.') == -1:
        request.json['last_watered'] = request.json['last_watered'] + '.000000'

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if str(user) == '[]':
            abort(401)
        user = user[0]
        # need to do str(i) because user.gardens is a list of ObjectIdFields
        if garden_id in [str(i) for i in user.gardens]:
            try:
                garden = gardens.objects(id=garden_id)
            except Exception as e:
                abort(404)
            if str(garden) == '[]':
                abort(404)
            garden = garden[0]

            try:
                plant_type = plant_types.objects(id=request.json['plant_type_id'])
            except Exception as e:
                abort(404)
            if str(plant_type) == '[]':
                abort(404)
            plant_type = plant_type[0]

                #request.json['last_watered']
            user_plant = user_plants(plant_type_id=request.json['plant_type_id'],
                latitude=request.json['latitude'],
                longitude=request.json['longitude'],
                light_duration=request.json['light_duration'],
                light_intensity=request.json['light_intensity'],
                name=request.json['name'],
                price=request.json['price'],
                outdoors=request.json['outdoors'],
                last_watered=datetime.datetime.strptime(request.json['last_watered'], '%Y-%m-%d %H:%M:%S.%f')).save()
            garden.plants.append(str(user_plant.id))
            garden.save()

            return {"id": str(user_plant.id)}, 200
        else:
            abort(401)

@greenthumb.app.route('/api/v1/usergarden/<string:garden_id>/edit_plant/<string:plant_id>/', methods=['PUT'])
def edit_plant_in_garden(garden_id: str, plant_id: str):

    expected_fields = ['plant_type_id', 'latitude',
        'longitude', 'light_duration', 'light_intensity', 'last_watered', 'name', 'price', 'outdoors']

    if 'email' not in session:
        abort(403)


    if not is_valid_id(garden_id):
        abort(401)


    if not is_valid_id(plant_id):
        abort(401)


    # check that the right info was provided, else 401
    for field in expected_fields:
        if field not in request.json:
             # Don't reject if still using the old set of expected fields
            if field in ['light_duration', 'light_intensity', 'price']:
                request.json[field] = 0
            elif field == 'name':
                request.json['name'] = ''
            elif field == 'outdoors':
                request.json['outdoors'] = True
            else:
                abort(401)

    if not is_valid_id(request.json['plant_type_id']):
        abort(401)


    if request.json['last_watered'].find('.') == -1:
        request.json['last_watered'] = request.json['last_watered'] + '.000000'

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if str(user) == '[]':
            abort(401)
        user = user[0]
        # need to do str(i) because user.gardens is a list of ObjectIdFields
        if garden_id in [str(i) for i in user.gardens]:
            try:
                garden = gardens.objects(id=garden_id)
            except Exception as e:
                abort(404)
            if str(garden) == '[]':
                abort(404)
            garden = garden[0]
            # same as above
            if plant_id not in [str(i) for i in garden.plants]:
                abort(401)
            try:
                plant_type = plant_types.objects(id=request.json['plant_type_id'])
            except Exception as e:
                abort(404)

            if str(plant_type) == '[]':
                abort(404)

            plant_type = plant_type[0]

            try:
                plant = user_plants.objects(id=plant_id)
            except Exception as e:
                abort(404)
            if str(plant) == '[]':
                abort(404)
            plant = plant[0]

            plant.plant_type_id = plant_type.id
            plant.latitude = request.json['latitude']
            plant.longitude = request.json['longitude']
            plant.light_duration = request.json['light_duration']
            plant.light_intensity = request.json['light_intensity']
            plant.name = request.json['name']
            plant.price = request.json['price']
            plant.outdoors = request.json['outdoors'],
            plant.last_watered = datetime.datetime.strptime(request.json['last_watered'], '%Y-%m-%d %H:%M:%S.%f')
            plant.save()

        else:
            abort(401)

    return "", 200

@greenthumb.app.route('/api/v1/usergarden/<string:garden_id>/delete_plant/<string:plant_id>/', methods=['DELETE'])
def delete_plant_in_garden(garden_id: str, plant_id: str):

    if 'email' not in session:
        abort(403)

    if not is_valid_id(garden_id):
        abort(401)
    if not is_valid_id(plant_id):
        abort(401)

    with util.MongoConnect():
        user = users.objects(email=session['email'])
        if str(user) == '[]':
            abort(401)
        user = user[0]
        # need to do str(i) because user.gardens is a list of ObjectIdFields
        if garden_id in [str(i) for i in user.gardens]:
            try:
                garden = gardens.objects(id=garden_id)
            except Exception as e:
                abort(404)
            if str(garden) == '[]':
                abort(404)
            garden = garden[0]
            # same as above
            if plant_id not in [str(i) for i in garden.plants]:
                abort(401)

            try:
                plant = user_plants.objects(id=plant_id)
            except Exception as e:
                abort(404)
            if str(plant) == '[]':
                abort(404)
            plant = plant[0]

            plant_type = plant_types.objects(id=str(plant.plant_type_id))
            if str(plant_type) == '[]':
                abort(401)
            plant_type = plant_type[0]

                #goes in place of "Water it": plant_type["watering_description"]
            garden.plants.remove(plant.id)
            garden.save()
            plant.delete()

        else:
            abort(401)

    return "", 200