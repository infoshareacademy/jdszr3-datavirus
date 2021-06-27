from injector import singleton
from src.services.MushroomsDataMapper import MushroomsDataMapper

def configure(binder):
    binder.bind(MushroomsDataMapper, to=MushroomsDataMapper, scope=singleton)
