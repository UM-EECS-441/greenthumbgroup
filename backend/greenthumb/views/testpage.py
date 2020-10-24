"""

GreenThumb server setup check page.
Allows admin to check that server is correctly configured by
providing a test route.

GreenThumb Group <greenthumb441@umich.edu>

"""
import greenthumb

@greenthumb.app.route('/', methods=["GET"])
def show_test():
    return "<h1>" +
        "If you're reading this, the server was configured correctly." +
        "</h1>" +
        "<p>GreenThumb group</p>"