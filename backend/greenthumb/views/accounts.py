import greenthumb

from greenthumb import util
from greenthumb.models.mongo import users
from flask import (request, session, redirect, url_for, abort)

"""

GreenThumb REST API: accounts.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/accounts/create/', methods=['GET', 'POST'])
def create_user():
    if 'email' in session:
        # TODO: change based on function name
        return redirect(url_for('get_user_gardens'))
    if request.method == 'POST':
        with util.MongoConnect():
            for user in users.objects():
                if request.json['email'] == user.email:
                    # TODO: Change later
                    return "", 200
            # insert into database, then login
            with util.MongoConnect():
                users(email=request.json['email'], gardens=[], unsubscribed=False).save()
            session['email'] = request.json['email']
            # TODO: change based on function name
            return "", 200
    # TODO: change this return
    return {}

@greenthumb.app.route('/accounts/login/', methods=['GET', 'POST'])
def login():
    if 'email' in session:
        # TODO: change based on function name
        return redirect(url_for('get_user_gardens'))
    if request.method == 'POST':
        with util.MongoConnect():
            for user in users.objects():
                if request.json['email'] == user.email:
                    session['email'] = user['email']
                    # TODO: change based on function name
                    return "", 200
            return "", 200
    # TODO: change this return
    return {}

@greenthumb.app.route('/accounts/logout/', methods=['GET'])
def logout():
    session.pop('email', None)

    # TODO: need different redirect
    return "", 200

@greenthumb.app.route('/accounts/subscribe/<string:user_email>/', methods=['GET'])
def subscribe(user_email: str):
    with util.MongoConnect():
        for user in users.objects():
            if user_email == user.email:
                user.unsubscribed = False
                user.save()
                return "Successfully subscribed.", 200
    return "User not found.", 404

@greenthumb.app.route('/accounts/unsubscribe/<string:user_email>/', methods=['GET'])
def unsubscribe(user_email: str):
    with util.MongoConnect():
        for user in users.objects():
            if user_email == user.email:
                user.unsubscribed = True
                user.save()
                return "Successfully unsubscribed.", 200
    return "User not found.", 404



