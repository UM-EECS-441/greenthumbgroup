"""

GreenThumb setup configuration.

GreenThumb Group <greenthumb441@umich.edu>

To install in your env, just run the following
in the directory of this file:

    pip install -e .

After this, you should be good to go with the Flask app.
Other prerequisite requirements may be required.

"""

from setuptools import setup

setup(
    name='greenthumb',
    version='1.0.0',
    packages=['greenthumb'],
    include_package_data=True,

<<<<<<< HEAD
    # TODO: Add any packages here that we need.
=======
    # TODO: More PACKAGESSSS
>>>>>>> d86e029a5a46bd2d2c2bf6158ae99e21e7b5f408
    install_requires=[
        'Flask',
        'Flask-PyMongo',
        'requests',
    ],
)