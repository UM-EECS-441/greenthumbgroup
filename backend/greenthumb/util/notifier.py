"""

GreenThumb notification system.

GreenThumb Group <greenthumb441@umich.edu>

"""

import sys, smtplib, ssl, sched, schedule

from os import name
from greenthumb import config
from email.message import EmailMessage
from crontab import CronTab

class Notifier:

    MSG_TITLE = "GreenThumb Task List for {tasks_date}"
    DIGEST_MSG = "Hey {username}! Here's your gardening task list for the day: "
    PLANT_MSG = "{plant_name} is a {plant_type} and is located at ({lat}, {long})."
    INSTR_MSG = "Here's what you need to do: {maintain_instr}"
    EXPLAIN_MSG = "Why this is important: {explanation}"

    WATER_MSG = "Water {plant_name}."
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

    def send_email_notification(self, rec_email, plant_name, lat, long, water_desc):

        with open(self.pass_filename, 'r') as email_pass_file:
            password = email_pass_file.readline()

        # Create a secure SSL context
        context = ssl.create_default_context()

        with smtplib.SMTP_SSL("smtp.gmail.com", self.port, context=context) as server:
            server.login(self.email_addr, password)
            # TODO: Send email here
            sender_email = self.email_addr

            message = EmailMessage()
            message.set_content(
                f"\tIt's time to water your {plant_name}!\n\n\
                Your plant is located at ({lat}, {long})\n\n\
                Watering instructions: {water_desc}"
            )
            message['Subject'] = f'Watering Notification for {plant_name.capitalize()}'
            message['From'] = self.email_addr
            message['To'] = rec_email

            server.send_message(message)
            server.quit()

    def create_notification(days_until=1, recurring=False):
        if recurring:
            with CronTab(user='root') as cron:
                pass

    def remove_notification(recurring=False):
        with CronTab(user='root') as cron:
            pass

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
# frost/cold
# heat/dry

# MAINTENANCE TYPES
# watering
# fertilizing
# pruning/trimming
# picking
# pest prevention
# weeding
# new planting
