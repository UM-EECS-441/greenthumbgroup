import greenthumb
from greenthumb import util

"""

GreenThumb REST API: notifications.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/accounts/create/', methods=['POST'])
def create_user():
    with util.MongoConnect():
        pass