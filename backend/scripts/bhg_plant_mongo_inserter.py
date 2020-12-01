from greenthumb.models.mongo import plant_types
import mongoengine
import pandas
import numpy as np
import pathlib
import os

# Catalog text file that will be inserted into the mongo database
# NOTE: catalog text file has to be located in the resources
# directory located in this file's parent directory
# this is currently:
# ../resources/plants_list_v2.txt
catalog_file = os.sep.join(os.path.dirname(os.path.abspath(__file__)).split(os.sep)[:-1])

catalog_file += os.sep + "resources" + os.sep \
    + "plants_list_v2.txt"
# print(catalog_file)

# Imports from txt file using pandas
catalog_df = pandas.read_csv(catalog_file, sep='|', header=0, index_col=False, keep_default_na=False)
print("Reading plants catalog file from: ")
print(catalog_file)

# Connects to the data database
mongoengine.connect("data")
print("Connected to mongodb \"data\" database")
# print(catalog_df.columns)

i = 0
# Iterates through each row in the plants list
# inserting it into the mongo database
# Will also update the document if you change
# a field in an object already saved in the document
print("Inserting/Updating plants in \"plant_types\" collection")
for row, plant in catalog_df.iterrows():
    
    # print(plant["plant name"])

    # Map of plant tags
    # key: string
    # value: list of strings
    plant_tags = {}

    # Iterates through all plant tags
    # adding them as list items to plant_tags
    # if they are a list item
    for tag, val in plant[plant.values != ""].items():
        if (tag != "name" and tag != "species" \
            and tag != "description" and tag != "image"):
            
            # Adds plant tags and splits on commas
            plant_tags[tag] = val.split(", ")

        #plant_tags[tag]

    # Saves the plant to the catalog document
    plant_types(name = plant["name"],
        species = plant["species"],
        tags = plant_tags,
        description = plant["description"]).save()

    i+= 1

print("Saved {} plants in catalog".format(i))
