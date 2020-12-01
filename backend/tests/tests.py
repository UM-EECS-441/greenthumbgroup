
import unittest
from mongoengine import connect, disconnect
import multiprocessing as mp
import sys

from greenthumb.models.mongo import users, plant_types, gardens, user_plants, guides

from plant_types_test import Plant_Types_Test_Suite
from guides_test import Guides_Test_Suite

"""
A series of unit tests for both the web app and database
Run using: python tests.py
"""

def run_app():
    """
    run's app on 127.0.0.1:5000
    and changes the MONGO_URI to test
    NOTE: will block so this func needs to run
    in another process with
    stdout redirected to app.log
    """
    from greenthumb import app

    # Redirects stdout to file
    sys.stdin = None
    sys.sderr = sys.stdout
    sys.stdout = open("test_app.log", "w")

    # Changing the database to point to the test
    # database, which we will allocate and deallocate
    # new collections at will
    app.config["MONGO_URI"] = "test"

    # Runs app locally and in debug mode with test database
    app.run()


if __name__ == '__main__':

    # # Runs server in another process
    # app_process = mp.Process(target=run_app)
    # app_process.start()

    test_classes_to_run = [Plant_Types_Test_Suite, Guides_Test_Suite]

    loader = unittest.TestLoader()

    suites_list = []

    for test_class in test_classes_to_run:
        suite = loader.loadTestsFromTestCase(test_class)
        suites_list.append(suite)
    
    comprehensive_test_suite = unittest.TestSuite(suites_list)

    runner = unittest.TextTestRunner(verbosity=2)
    results = runner.run(comprehensive_test_suite)

    # Kills app process since all tests have run
    # app_process.terminate()
    # app_process.join()