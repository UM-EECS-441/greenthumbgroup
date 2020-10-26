import greenthumb

from greenthumb import util
from greenthumb.models.mongo import users
from flask import (request, session, redirect, url_for, abort)

"""

GreenThumb REST API: accounts.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/accounts/create/', methods=['GET', 'POST'])
def create_user():
    if 'email' in session:
        # TODO: change based on function name
        return redirect(url_for('user_gardens'))
    if request.method == 'POST':
        with util.MongoConnect():
            for user in users.objects():
                if request.form['email'] == user.email:
                    # TODO: Change later
                    return redirect(url_for('login'))
            # insert into database, then login
            with util.MongoConnect():
                users(email=request.form['email'], gardens=[]).save()
            session['email'] = request.form['email']
            # TODO: change based on function name
            return redirect(url_for('user_gardens'))
    # TODO: change this return
    return {}

@greenthumb.app.route('/api/v1/accounts/login/', methods=['GET', 'POST'])
def login():
    if 'email' in session:
        # TODO: change based on function name
        return redirect(url_for('user_gardens'))
    if request.method == 'POST':
        with util.MongoConnect():
            for user in users.objects():
                if request.form['email'] == user.email:
                    session['email'] = user['email']
                    # TODO: change based on function name
                    return redirect(url_for('user_gardens'))
            return redirect(url_for('create_user'))
    # TODO: change this return
    return {}

@greenthumb.app.route('/api/v1/accounts/logout', methods=['GET'])
def logout():
    session.pop('email', None)

    # TODO: need different redirect
    return redirect(url_for('login'))