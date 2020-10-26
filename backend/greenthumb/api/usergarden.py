import greenthumb

from greenthumb import util
from greenthumb.models.mongo import users
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
        for garden_id in users.objects(email=session['email'])[0].gardens:
            pass

    return jsonify(user_gardens)

@greenthumb.app.route('api/v1/usergarden/<int:garden_id>', methods=['GET'])
def get_garden(garden_id: int):

    if 'email' not in session:
        abort(403)

    garden = {}

    with util.MongoConnect():
        garden = users.objects(email=session['email'])[0].gardens

    return garden
