
from mongoengine import connect, disconnect
import unittest
from greenthumb.models.mongo import guides

from greenthumb import app
import requests
import json

class Guides_Test_Suite(unittest.TestCase):
    """
    Tests the guides db and its functions
    """

    def __init__(self, *args, **kwargs):
            super(Guides_Test_Suite, self).__init__(*args, **kwargs)
            # Catalog api url for localhost
            self.url = "http://127.0.0.1:5000/api/v1/guides/"

    def setUp(self):
        """
        Runs before each test
        """

        # connects to the test database to
        connect("test")

        guides.drop_collection()
        
        
        # Adds 3 guides to the database
        self.g1 = guides(title="g1_title",
            text="g1_text lorem ipsum").save()

        self.g2 = guides(title="g2_title",
            text="g2_text dico linguam").save()

        self.g3 = guides(title="g3_title",
            text="g3_text iacto sagittaem").save()

    def tearDown(self):
        """
        Runs after all tests
        """
        # Removes all documents from the plant_types collection
        # and disconnects from the mongo engine
        guides.drop_collection()
        
        disconnect()
    
    def test_get_guides(self):
        """
        tests querying the plant types db for all documents
        """
        
        response = requests.get(self.url)

        # Checks if request was received as 200
        self.assertEqual(response.status_code, 200)
        
        guides_arr = [self.g1.to_dict(), self.g2.to_dict(), self.g3.to_dict()]
        
        # Checks if the lists are equal
        self.assertListEqual(guides_arr, response.json())
        

    def test_get_guide_single(self):
        """
        tests querying the plant_types db for one plant
        """
        
        response = requests.get(self.url + str(self.g1.id))

        # Checks if request was received as 200
        self.assertEqual(response.status_code, 200)

        # Checks if plant request was equal to one in database
        self.assertDictEqual(self.g1.to_dict(), response.json())