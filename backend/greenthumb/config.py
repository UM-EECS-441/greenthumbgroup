"""

GreenThumb dev config.

GreenThumb Group <greenthumb441@umich.edu>

"""

import os

APPLICATION_ROOT = '/'

# TODO: Set this to the local mongo location or something idk
MONGO_URI = "data"

# Optional stuff ahead if we decide to set up cookies, login
# etc. though not sure how it would work with Apple sign in

SECRET_KEY = (b'\x89H\xa9\x19\xedJ\xf2Y\x0f*\xa4G \
                    \x07\x9a\xb6\xd8\xfb\t\xe7\x12\x7fh\x8e\xfc')
# SESSION_COOKIE_NAME = ''

# UPLOAD_FOLDER = ''
# ALLOWED_EXTENSIONS = set([])
# MAX_CONTENT_LENGTH = 0