"""

GreenThumb views for web pages.

GreenThumb Group <greenthumb441@umich.edu>

"""

# TODO: In case we need any views, seems like we only need api stuff atm.
# Create .py files for views and import here.
from greenthumb.views.testpage import (show_test)
from greenthumb.views.accounts import (create_user, login, logout, subscribe, unsubscribe)