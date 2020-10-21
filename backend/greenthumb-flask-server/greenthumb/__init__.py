"""

GreenThumb package initialization.

GreenThumb Group <greenthumb441@umich.edu>

"""

import flask

# TODO: May need to setup a models dir/package at some point
# import greenthumb.models

application = flask.Flask(__name__)

application.config.from_object('greenthumb.config')
application.config.from_envvar('GREENTHUMB_SETTINGS', silent=True)

import greenthumb.api
import greenthumb.views
import greenthumb.models