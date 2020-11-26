"""

GreenThumb notification system.

GreenThumb Group <greenthumb441@umich.edu>

"""

from greenthumb.models.tasks import WateringTask
import sys, smtplib, ssl, sched, schedule

from os import name
from greenthumb import config
from email.message import EmailMessage
from crontab import CronTab
from greenthumb import util
from greenthumb.models.mongo import (users, gardens, plant_types, user_plants)
from datetime import date

class Notifier:

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

    def send_task_lists(self):

        """

        Generate and send task_lists for all subscribed users.

        """

        with util.MongoConnect():
            usrs = users.objects()
            for usr in usrs:
                if not usr.unsubscribed:
                    water_tasks, weather_tasks = self.generate_user_tasks(usr)
                    email_msg = self.create_email_msg(water_tasks, weather_tasks)
                    email_topic = self.MSG_TITLE.format(tasks_date=date.today())
                    self.send_email_notification(email_content=email_msg, email_subject=email_topic)

    def generate_user_tasks(self, usr):

        """

        Generate task lists for a user.

        """

        watering_tasks = []
        weather_tasks = []

        for garden_id in usr.gardens:
            hist_data, forecast_data, plant_watering_data = util.calc_garden_plants_watering(garden_id)
            garden = gardens.objects(id=garden_id)[0]
            for plant_id in garden.plants:
                plant = user_plants.objects(id=plant_id)[0]
                last_watered_date = plant.last_watered
                plant_type = plant_types.objects(id=plant.plant_type_id)[0]
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

        return watering_tasks, weather_tasks

    def create_email_msg(self, usr, water_tasks, weather_tasks):

        """

        Create an email message string from a task list.

        """

        # email_subject = self.MSG_TITLE.format(tasks_date=date.today()) + "\n\n"

        email_msg = (
            self.DIGEST_MSG.format(username=usr.email) +
            "\n\n" +
            self.WATER_MSG + 
            "\n"
        )

        for wt in water_tasks:
            email_msg.append(
                "- " +
                self.PLANT_MSG.format(
                    plant_name=wt.plant_name,
                    plant_type=wt.plant_type,
                    lat=wt.plant_lat,
                    long=wt.plant_long
                ) +
                self.INSTR_MSG.format(
                    maintain_instr=wt.water_instr
                ) +
                "\n"
            )

        return email_msg

    def send_email_notification(self, rec_email, email_subject, email_content):

        """

        Send an email message to a user's email address.
        
        """

        with open(self.pass_filename, 'r') as email_pass_file:
            password = email_pass_file.readline()

        # Create a secure SSL context
        context = ssl.create_default_context()

        with smtplib.SMTP_SSL(self.smtp_serv, self.port, context=context) as server:
            server.login(self.email_addr, password)
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
        user=config.CRON_USER,
        email_addr=config.NOTIF_EMAIL_ADDR,
        pass_filename=config.NOTIF_EMAIL_PASS_FILE,
        smtp_serv=config.EMAIL_SMTP,
        port=config.EMAIL_SSL_PORT)
    notif.send_email_notification(
        str(sys.argv[1]),
        str(sys.argv[2]),
        str(sys.argv[3]),
        str(sys.argv[4]),
        " ".join(list(sys.argv[5:]))
    )

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

# RECALCULATE EVERY MORNING BASED ON WEATHER (CONSIDER ZONE FOR LOWEST SURVIVABLE TEMPS)
