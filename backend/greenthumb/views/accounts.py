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
        return redirect(url_for('user_gardens'))
    if request.method == 'POST':
        with util.MongoConnect():
            for user in users.objects():
                if request.json['email'] == user.email:
                    # TODO: Change later
                    return redirect(url_for('login'))
            # insert into database, then login
            with util.MongoConnect():
                users(email=request.json['email'], gardens=[]).save()
            session['email'] = request.json['email']
            # TODO: change based on function name
            return redirect(url_for('get_user_gardens'))
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
                    return redirect(url_for('get_user_gardens'))
            return redirect(url_for('create_user'))
    # TODO: change this return
    return {}

@greenthumb.app.route('/accounts/logout', methods=['GET'])
def logout():
    session.pop('email', None)

    # TODO: need different redirect
    return redirect(url_for('login'))