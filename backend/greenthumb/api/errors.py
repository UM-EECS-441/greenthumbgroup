import greenthumb

from flask import make_response, jsonify

"""

GreenThumb REST API: errors.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.errorhandler(400)
def bad_request(error):

    """ Handle a 400 error """

    return make_response(
        jsonify({
            "message": "Bad Request",
            "status_code": "400"
        }),
        400
    )

@greenthumb.app.errorhandler(403)
def bad_request(error):

    """ Handle a 403 error """

    return make_response(
        jsonify({
            "message": "Forbidden",
            "status_code": "403"
        }),
        403
    )

@greenthumb.app.errorhandler(404)
def bad_request(error):

    """ Handle a 404 error """

    return make_response(
        jsonify({
            "message": "Not Found",
            "status_code": "404"
        }),
        404
    )
