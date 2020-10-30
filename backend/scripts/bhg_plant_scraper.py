from bs4 import BeautifulSoup
import numpy as np
import pandas as pd

# Possible plant attributes
attributes = ["plant name", "plant species", "zones",
    "light", "flower color", "foliage color", "plant type",
    "height", "season features", "special features", "problem solvers", "Description"]

with open("plant_encyclopedia.html", encoding="utf-8") as plant_file:
    soup = BeautifulSoup(plant_file, "html.parser")

# Gets number of plants in file
num_plants = soup.find_all("div", class_="tout__countent")
# Number of possible plant attributes
num_attributes = len(attributes)



# Numpy array of plant attributes used to write
# to output text file delimited by the pipe symbol (|)
plant_arr = [""] * num_attributes

with open("plants_list.txt", "w+", encoding="utf-8") as out_file:

    # Outputs Headers
    out_file.write("|".join(attributes) + "\n")

    for pind, plant in enumerate(soup.find_all("div", class_="tout__content")):


        # Sets plant name and species
        plant_arr[0:2] = plant.find("span", class_="tout_titleLinkText").text.strip().split(", ")
        
        # The following will only iterate through all plants
        # adding their attributes to the plant array if they exist
        for list_item in plant.find_all("li", class_="tout__contentListItem"):
            attr_ind = attributes.index(list_item.find("strong", class_="tout__contentListLabel").text[:-1])
            plant_arr[attr_ind] = list_item.find("span", class_="tout__contentListItemValue").text.strip()

        # Adds Description to numpy array
        
        plant_arr[-1] = plant.find("div", class_="tout__summary").text.strip()

        # Modifies Plant Description
        plant_arr[-1] = plant_arr[-1].replace("\n", "")


        # Writes to file with each field joined by
        # the Pipe Character
        out_file.write("|".join(plant_arr) + "\n")

        # Clears plant_arr
        plant_arr = [""] * num_attributes