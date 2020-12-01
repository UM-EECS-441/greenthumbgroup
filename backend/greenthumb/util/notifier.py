"""

GreenThumb notification system.

GreenThumb Group <greenthumb441@umich.edu>

"""

from greenthumb.util.zonetemp import zone_min_temp
import smtplib, ssl, sys

from os import name
from greenthumb import config
from email.message import EmailMessage
from greenthumb import util
from greenthumb.models.mongo import (users, gardens, plant_types, user_plants)
from greenthumb.models.tasks import (WateringTask, ColdWeatherTask)
from datetime import date
class Notifier:

    # SPECIAL CONDITIONS
    # rain/wet
    # frost/cold (create list of plants that need to be brought in/covered)
    # heat/dry

    # MAINTENANCE TYPES
    # watering
    # fertilizing
    # pruning/trimming
    # picking
    # pest prevention
    # weeding
    # new planting

    MSG_TITLE = "GreenThumb Task List for {tasks_date}"
    DIGEST_MSG = "Hey {username}! Here's your gardening task list for the day: "
    PLANT_MSG = "{plant_name} is a {plant_type} and is located at ({lat}, {long}). "
    INSTR_MSG = "Here's what you need to do: {maintain_instr}"
    EXPLAIN_MSG = "Why this is important: {explanation}"

    WATER_MSG = "Water these plants today: "
    FERTILIZE_MSG = "Fertilize {plant_name}."
    TRIM_MSG = "Trim {plant_name}."
    HARVEST_MSG = "Harvest {plant_name}."
    WEEDING_MSG = "Remove pesky weeds from your garden!"
    COLD_MSG = ("Today's minimum temperature is {temp_today} degrees C and " +
        "tomorrow's is {temp_tomorrow} degrees C. You may want to bring these " +
        "plants inside or cover them up: ")
    ZONE_MSG = ("This plant's zone is {zone_num} which means it can handle a " +
        "minimum temperature of approximately {low_deg} degrees C.")

    # Optionals?
    PEST_PREV_MSG = "Take some pest-prevention measures in your garden!"
    PRUNE_MSG = "Prune {plant_name}."
    PLANT_SUGGEST_MSG = "Based on the plants in your garden, we think you should consider adding some {plant_type}s!"
    
    def __init__(self, user, email_addr, pass_filename, smtp_serv, port):
        self.user = user
        self.email_addr = email_addr
        self.pass_filename = pass_filename
        self.smtp_serv = smtp_serv
        self.port = port

    def send_all_task_lists(self):

        """

        Generate and send task lists for all subscribed users.

        """

        with util.MongoConnect():
            usrs = users.objects()
            for usr in usrs:
                self.generate_and_send_task_list(usr)

    def generate_and_send_task_list(self, usr):

        """

        Generate and send a task list for a single user.

        """

        if not usr.unsubscribed:
            water_tasks, cold_weather_tasks, min_temp_today, min_temp_tomorrow = self.generate_user_tasks(usr)
            if water_tasks or cold_weather_tasks:
                email_msg = self.create_email_msg(usr, water_tasks, cold_weather_tasks, min_temp_today, min_temp_tomorrow)
                email_topic = self.MSG_TITLE.format(tasks_date=date.today())
                self.send_email_msg(rec_email=usr.email, email_content=email_msg, email_subject=email_topic)

    def generate_user_tasks(self, usr):

        """

        Generate task lists for a user.

        """

        min_temp_today = None
        min_temp_tomorrow = None
        watering_tasks = []
        cold_weather_tasks = []

        for garden_id in usr.gardens:
            garden_weather_data = util.calc_garden_plants_watering(garden_id)
            # in degrees C
            if garden_weather_data[0] and garden_weather_data[1]:
                min_temp_today = garden_weather_data["forecast_data"][0]["min_temp"]
                min_temp_tomorrow = garden_weather_data["forecast_data"][1]["min_temp"]
            garden = None
            with util.MongoConnect():
                gardens_found = gardens.objects(id=garden_id)
                if gardens_found:
                    garden = gardens_found[0]
            if garden:
                for plant_id in garden.plants:
                    plant = None
                    plant_type = None
                    with util.MongoConnect():
                        plants_found = user_plants.objects(id=plant_id)
                        plant_types_found = plant_types.objects(id=plant.plant_type_id)
                        if plants_found and plant_types_found:
                            plant = plants_found[0]
                            plant_type = plant_types_found[0]
                    if plant and plant_type:
                        last_watered_date = plant.last_watered
                        days_to_water = plant_type.days_to_water
                        if (date.today() - last_watered_date).days >= days_to_water:
                            watering_tasks.append(
                                WateringTask(
                                    plant_name=plant.name,
                                    plant_type=plant_type.name,
                                    plant_lat=plant.latitude,
                                    plant_long=plant.longitude,
                                    water_instr=plant_type.watering_description,
                                )
                            )
                        if plant.outdoors and min_temp_today and min_temp_tomorrow and "zones" in plant_type.tags:
                            min_zone = min(plant_type.tags["zones"])
                            if min_temp_today < util.zone_min_temp(min_zone) or min_temp_tomorrow < util.zone_min_temp(min_zone):
                                cold_weather_tasks.append(
                                    ColdWeatherTask(
                                        plant_name=plant.name,
                                        plant_type=plant_type.name,
                                        plant_lat=plant.latitude,
                                        plant_long=plant.longitude,
                                        plant_zone=min_zone,
                                    )
                                )

        return watering_tasks, cold_weather_tasks, min_temp_today, min_temp_tomorrow

    def create_email_msg(self, usr, water_tasks, cold_weather_tasks, min_temp_today, min_temp_tomorrow):

        """

        Create an email message string from a task list.

        """

        # email_subject = self.MSG_TITLE.format(tasks_date=date.today()) + "\n\n"

        email_msg = (
            self.DIGEST_MSG.format(username=usr.email) +
            "\n"
        )

        if water_tasks:
            email_msg = email_msg + (
                "\n" +
                self.WATER_MSG + 
                "\n"
            )

            for wt in water_tasks:
                email_msg = email_msg + (
                    "- " +
                    self.PLANT_MSG.format(
                        plant_name=wt.plant_name,
                        plant_type=wt.plant_type,
                        lat=str(wt.plant_lat),
                        long=str(wt.plant_long)
                    ) +
                    self.INSTR_MSG.format(
                        maintain_instr=wt.water_instr
                    ) if wt.water_instr else "" +
                    "\n"
                )
        if cold_weather_tasks and min_temp_today and min_temp_tomorrow:
            email_msg = email_msg + (
                "\n" +
                self.COLD_MSG.format(
                    temp_today=str(min_temp_today),
                    temp_tomorrow=str(min_temp_tomorrow)
                ) +
                "\n"
            )
            for wt in cold_weather_tasks:
                email_msg = email_msg + (
                    "- " +
                    self.PLANT_MSG.format(
                        plant_name=wt.plant_name,
                        plant_type=wt.plant_type,
                        lat=str(wt.plant_lat),
                        long=str(wt.plant_long)
                    ) +
                    self.ZONE_MSG.format(
                        zone_num=str(wt.plant_zone),
                        low_deg=str(zone_min_temp(wt.plant_zone))
                    ) +
                    "\n"
                )

        email_msg = email_msg + (
            "\n" +
            "Don't want these notifications? Unsubscribe here: http://192.81.216.18/accounts/unsubscribe/" +
            str(usr.email) +
            "/" +
            "\n"
        )
        return email_msg

    def send_email_msg(self, rec_email, email_subject, email_content):

        """

        Send an email message to a user's email address.
        
        """

        password = ""

        with open(self.pass_filename, 'r') as email_pass_file:
            password = email_pass_file.readline()

        # Create a secure SSL context
        context = ssl.create_default_context()

        with smtplib.SMTP_SSL(self.smtp_serv, self.port, context=context) as server:
            server.login(user=str(self.email_addr), password=str(password))
            # TODO: Send email here
            sender_email = self.email_addr

            message = EmailMessage()
            message.set_content(email_content)
            message['Subject'] = email_subject
            message['From'] = self.email_addr
            message['To'] = rec_email

            server.send_message(message)
            server.quit()

if __name__ == "__main__":
    notif = Notifier(
        user="root",
        email_addr=config.NOTIF_EMAIL_ADDR,
        pass_filename=config.NOTIF_EMAIL_PASS_FILE,
        smtp_serv=config.EMAIL_SMTP,
        port=config.EMAIL_SSL_PORT
    )
    with util.MongoConnect():
        usr = users.objects(email=sys.argv[1])[0]
        notif.generate_and_send_task_list(usr)
