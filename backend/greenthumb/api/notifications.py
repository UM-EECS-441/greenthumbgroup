import greenthumb

from greenthumb import util

"""

GreenThumb REST API: notifications.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('api/v1/notifications/<int:user_id>/', methods=['GET'])
def get_user_notifications(user_id: int):

    notifications = []

    with util.MongoConnect():
        print("hello")