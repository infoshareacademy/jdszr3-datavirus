from flask import Flask
from flask_injector import FlaskInjector
from dependencies import configure
from src.controllers.MainController import main_controller

app = Flask(__name__)
app.register_blueprint(main_controller)
app.secret_key = "datavirus" # needed for decrypting the data send to/from database


FlaskInjector(app=app, modules=[configure])

if __name__ == "__main__":
    app.debug = True
    app.run(port=3000)