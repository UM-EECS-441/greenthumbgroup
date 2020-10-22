import greenthumb

"""

GreenThumb REST API: plant catalog.

GreenThumb Group <greenthumb441@umich.edu>

"""

@greenthumb.app.route('/api/v1/catalog/', methods=['GET'])
def get_catalog():

    """ Route to get the catalog plant list """

    # TODO: Implement, figure out how to do it by page number.

    pass

@greenthumb.app.route('/api/v1/catalog/<int:plant_id>/', methods=['GET'])
def get_catalog_plant_page(plant_id: int):

    """ Route to get a plant page from the catalog """

    # TODO: Implement.

    pass