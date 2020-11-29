from google_images_download import google_images_download as gimage
import mongoengine
import pandas
import numpy as np
import pathlib
import os
import random
from time import sleep
import base64
from PIL import Image
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


print("Adding images of plants to file: ")
# plant_images_b64 = []
# print(catalog_outfile)

# Class that will handle image downloads
response = gimage.googleimagesdownload()
download_arguments = {"keywords": "", "limit": 1,
    "print_urls": True, "format": "jpg",
    "aspect_ratio": "square",
    "size": "medium", "suffix_keywords": "plant",
    "output_directory": catalog_filedir,
    "no_directory": True}

# For each plant in the catalog
for row, plant in catalog_df.iterrows():
    
    try:
        # Downloads the image for that plant species
        download_arguments["keywords"] = plant["species"]
        paths = response.download(download_arguments)

        # Generates filename to be equal to the species name
        image_filestring = os.sep.split(paths[0][plant["species"] + " plant"][0])[:-1].join(os.sep) \
            + plant["species"] + ".jpg"

        # Renames plant file
        os.rename(r'' + paths[0][plant["species"] + " plant"][0], r'' + image_filestring)

        # Resizes the image to be a consisten 400x400 pixels
        image = Image.open(image_filestring)
        new_image = image.resize((400, 400))
        new_image.save(image_filestring)


        # Adds plants b64 image to database
        plant_doc = plant_types.objects(species=plant["species"])
        plant_doc.update(set__image=base64.b64encode(image_filestring.read()))

    except:
        # plant_images_b64.append("")
        print("Failed for " + plant["species"])

    sleep(random.uniform(1, 2.5))


catalog_df["image"] = plant_images_b64

print("Writing to outfile")
catalog_df.to_csv(catalog_outfile, index=False ,sep='|', na_rep="", header=True)