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
    
    # TODO: Add any packages here that we need.
    install_requires=[
        'wheel',
        'Flask',
        'flask-mongoengine',
        'gunicorn',
        'requests',
        'pandas',
        'python-crontab',
        'schedule',
    ],
)