
from mongoengine import connect, disconnect
import unittest
from greenthumb.models.mongo import plant_types

from greenthumb import app
import requests
import json

class Plant_Types_Test_Suite(unittest.TestCase):
    """
    Tests the plant_types db and its functions
    """

    def __init__(self, *args, **kwargs):
        super(Plant_Types_Test_Suite, self).__init__(*args, **kwargs)
        # Catalog api url for localhost
        self.url = "http://127.0.0.1:5000/api/v1/catalog/"

    def setUp(self):
        """
        Runs before each test
        """

        # connects to the test database to
        connect("test")

        plant_types.drop_collection()
        
        # Adds 3 plants to the database
        self.p1 = plant_types(name="p1_name",
            species="p1_species",
            tags = {"flower color": ["red"], "zones": ["1","2","3","4"]},
            description = "pl description.....").save()

        self.p2 = plant_types(name="p2_name",
                    species="p2_species",
                    tags = {"flower color": ["red"], "zones": ["5","6","7"], "light": ["Sun"]},
                    description = "p2 description.....").save()

        self.p3 = plant_types(name="p3_name",
        species="p3_species",
        tags = {"zones": ["3", "4", "5", "6"], "light": ["Shade"]},
        description = "p3 description.....").save()

    def tearDown(self):
        """
        Runs after all tests
        """
        # Removes all documents from the plant_types collection
        # and disconnects from the mongo engine
        plant_types.drop_collection()
        
        disconnect()
    
    def test_get_catalog(self):
        """
        tests querying the plant types db for all documents
        """
        
        response = requests.get(self.url)

        # Checks if request was received as 200
        self.assertEqual(response.status_code, 200)
        
        catalog_arr = [self.p1.to_dict(), self.p2.to_dict(), self.p3.to_dict()]
        
        # Checks if the lists are equal
        self.assertListEqual(catalog_arr, response.json())
        

    def test_get_catalog_plant(self):
        """
        tests querying the plant_types db for one plant
        """
        
        response = requests.get(self.url + str(self.p1.id))

        # Checks if request was received as 200
        self.assertEqual(response.status_code, 200)

        # Checks if plant request was equal to one in database
        self.assertDictEqual(self.p1.to_dict(), response.json())