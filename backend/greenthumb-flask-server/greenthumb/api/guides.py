import greenthumb

"""

GreenThumb REST API: guides.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/guides/', methods=['GET'])
def get_guides():

    """ Route to get the guide page list """

    # TODO: Implement, figure out how to do it by page number.

    pass

@greenthumb.app.route('/api/v1/guides/<int:guide_page_id>/', methods=['GET'])
def get_guide_page(guide_page_id: int):

    """ Route to get a guide page """

    # TODO: Implement.

    pass