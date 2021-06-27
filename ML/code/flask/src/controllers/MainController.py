from flask import render_template, request, Blueprint
from injector import inject
import joblib
import pandas as pd
from src.services.MushroomsDataMapper import MushroomsDataMapper

main_controller = Blueprint('main_controller', __name__, template_folder='templates')

@main_controller.route("/", methods=["POST", "GET"])
def index():
    return render_template("form.html")

@inject
@main_controller.route("/results", methods=["POST"])
def results(mushroomsDataMapper: MushroomsDataMapper):
    msg=mushroomsDataMapper.mapMushroomsData(request.form)
    return render_template("results.html",msg=msg)