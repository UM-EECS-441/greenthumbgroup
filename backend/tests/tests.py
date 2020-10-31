from mongoengine import connect, disconnect
import unittest
from greenthumb.models.mongo import users, plant_types, gardens, user_plants, guides

from greenthumb import app

from plant_types_test import Plant_Types_Test_Suite
from guides_test import Guides_Test_Suite
"""
A series of unit tests for both the web app and database
Run using: python tests.py
"""



if __name__ == '__main__':
    
    # Changing the database to point to the test
    # database, which we will allocate and deallocate
    # new collections at will
    app.config["MONGO_URI"] = "test"

    # Runs app locally with test database
    app.run()

    test_classes_to_run = [Plant_Types_Test_Suite, Guides_Test_Suite]

    loader = unittest.TestLoader()

    suites_list = []

    for test_class in test_classes_to_run:
        suite = loader.loadTestsFromTestCase(test_classes_to_run)
        suites_list.append(suite)
    
    comprehensive_test_suite = unittest.TestSuite(suites_list)

    runner = unittest.TextTestRunner(suites_list, verbosity=2)
    results = runner.run(comprehensive_test_suite)

    unittest.main(verbosity=2)