"""

GreenThumb package initialization.

GreenThumb Group <greenthumb441@umich.edu>

"""

import flask

# TODO: May need to setup a models dir/package at some point
# import greenthumb.models

app = flask.Flask(__name__)

app.config.from_object('greenthumb.config')
app.config.from_envvar('GREENTHUMB_SETTINGS', silent=True)

import greenthumb.api
import greenthumb.views
import greenthumb.models