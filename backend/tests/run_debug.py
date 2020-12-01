from mongoengine import connect, disconnect
from greenthumb import app
import sys
import os

if __name__ == "__main__":
    
    """
    run's app on 127.0.0.1:5000
    and changes the MONGO_URI to test
    NOTE: will block so this func needs to run
    in another process with
    stdout redirected to app.log
    """

    # Runs app with flask debug
    # will change mongoconnect to use test database
    # Only runs debug for this python/terminal instance
    os.environ["FLASK_DEBUG"] = "1"

    # Redirects stdout to file
    sys.sderr = sys.stdout
    sys.stdout = open("test_app.log", "w")

    # Changing the database to point to the test
    # database, which we will allocate and deallocate
    # new collections at will
    app.config["MONGO_URI"] = "test"

    # Runs app locally and in debug mode with test database
    app.run()