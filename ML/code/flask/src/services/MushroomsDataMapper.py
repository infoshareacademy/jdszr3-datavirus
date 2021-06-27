import joblib
import pandas as pd
import os

class MushroomsDataMapper:
    @staticmethod
    def mapMushroomsData(mushroomData):
        print(mushroomData)

        extractedFormData = {value: 1 for key, value in mushroomData.items()}

        defaultValues = {'cap-shape_b': 0, 'cap-shape_f': 0, 'cap-shape_other': 0, 'cap-shape_s': 0, 'cap-shape_x': 0, 'cap-surface_f': 0, 'cap-surface_g': 0, 'cap-surface_s': 0, 'cap-surface_y': 0, 'cap-color_e': 0, 'cap-color_g': 0, 'cap-color_n': 0, 'cap-color_other': 0, 'cap-color_w': 0, 'cap-color_y': 0, 'bruises_f': 0, 'bruises_t': 0, 'gill-spacing_c': 0, 'gill-spacing_w': 0, 'stalk-shape_e': 0, 'stalk-shape_t': 0, 'ring-number_n': 0, 'ring-number_o': 0, 'ring-number_t': 0}

        def map(key, defaultValues, extractedFormData):
            if key in extractedFormData:
                return extractedFormData[key]

            return defaultValues[key]

        mappedDictionary = { key: map(key, defaultValues, extractedFormData) for (key, value) in defaultValues.items()}

        result={key:value for (key,value) in mappedDictionary.items()}


        test_data=pd.DataFrame(result, index=[0])

        model_dir = os.path.dirname(os.path.abspath(__file__))   
        model_path = os.path.join(model_dir, "models/RandomForestClassifier(max_depth=12, n_estimators=10).pkl")

        trained_model = joblib.load(model_path)

        prediction = trained_model.predict(test_data)
        msg=prediction[0]
        return msg
