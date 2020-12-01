import mongoengine
import pandas
import numpy as np
import pathlib
import os
import random
from time import sleep
import base64
from greenthumb.models.mongo import plant_types

# Catalog text file that will be inserted into the mongo database
# NOTE: catalog text file has to be located in the resources
# directory located in this file's parent directory
# this is currently:
# ../resources/plants_list_v2.txt
catalog_filedir = os.sep.join(os.path.dirname(os.path.abspath(__file__)).split(os.sep)[:-1]) + os.sep + "resources" + os.sep


catalog_infile = catalog_filedir + "plants_list_v2.txt"

# print(catalog_file)

# Connects to mongodb database data
mongoengine.connect("data")

# Imports from txt file using pandas
catalog_df = pandas.read_csv(catalog_infile, sep='|', header=0, index_col=False, keep_default_na=False)
print("Reading plants catalog file from: ")
print(catalog_infile)


print("Adding images of plants to database: ")

# For each plant in the catalog
for row, plant in catalog_df.iterrows():
    
    try:
       
        image_filestring = os.sep.join(catalog_filedir.split(os.sep)[:-2]) + os.sep + "images" + os.sep \
            + plant["species"].replace(" ", "_") + ".jpg"

        if os.path.isfile(image_filestring):
            plant_doc = plant_types.objects(species=plant["species"])
            plant_doc.update(set__image=base64.b64encode(open(image_filestring, 'rb').read()).decode('ascii'))

    except:
        # plant_images_b64.append("")
        print("Failed for " + plant["species"])
        # Adds empty string to database
        plant_doc = plant_types.objects(species=plant["species"])
        plant_doc.update(set__image="")