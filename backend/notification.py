import sys, smtplib, ssl

from os import name
from email.message import EmailMessage

def send_email_notification(rec_email, plant_name, lat, long, water_desc):

    port = 465  # For SSL
    email_addr = "greenthumbgroup441@gmail.com"
    password = ""

    with open("emailpass", 'r') as email_pass_file:
        password = email_pass_file.readline()

    # Create a secure SSL context
    context = ssl.create_default_context()

    with smtplib.SMTP_SSL("smtp.gmail.com", port, context=context) as server:
        server.login(email_addr, password)
        # TODO: Send email here
        sender_email = email_addr

        message = EmailMessage()
        message.set_content(
            f"\tIt's time to water your {plant_name}!\n\n\
            Your plant is located at ({lat}, {long})\n\n\
            Watering instructions: {water_desc}"
        )
        message['Subject'] = f'Watering Notification for {plant_name.capitalize()}'
        message['From'] = email_addr
        message['To'] = rec_email

        server.send_message(message)
        server.quit()

if __name__ == "__main__":
    send_email_notification(
        str(sys.argv[1]),
        str(sys.argv[2]),
        str(sys.argv[3]),
        str(sys.argv[4]),
        " ".join(list(sys.argv[5:]))
    )