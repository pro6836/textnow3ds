#Use pip install flask Flask jsonify pytextnow
from flask import Flask, request, jsonify
import pytextnow as pytn

app = Flask(__name__)

# Initialize the TextNow client
client = pytn.Client("", sid_cookie="", csrf_cookie="")  # Replace with your TextNow email and session cookie

# Endpoint to send a message
@app.route('/send', methods=['GET'])
def send_message():
    textpre = request.args.get('text')
    text = textpre.replace(":", " ")
    number = request.args.get('numb')
    
    try:
        client.send_sms(number, text)
        return "200: Sent"
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Endpoint to get messages
@app.route('/get', methods=['GET'])
def get_messages():
    number = request.args.get('numb')
    messages = "1upd"
    try:
        new_messages = client.get_unread_messages()
        for message in new_messages:
            numbercor = f"+{number}"
            #numbercor = "+16463842602"
            if message.number == numbercor:
                messages = message.content  # Store received message
                message.mark_as_read()  # Mark the message as read
        response = messages
        messages = "1upd"
        return response
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Start the server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
