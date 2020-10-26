import greenthumb
import flask
import json

from greenthumb import util

"""

GreenThumb REST API: guides.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/guides/', methods=['GET'])
def get_guides():

    """ Route to get the guide page list """

    guides = []

    with util.MongoConnect():
        for guide in greenthumb.models.mongo.guides.objects():
            guides.append(json.loads(guide.to_json()))

    return flask.jsonify(guides)

@greenthumb.app.route('/api/v1/guides/<int:guide_page_id>/', methods=['GET'])
def get_guide_page(guide_page_id: int):

    """ Route to get a guide page """

    # TODO: Implement.

    pass