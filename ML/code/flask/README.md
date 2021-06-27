## code created for flask application
Flask application is for predicting if the given mushroom is eatable or not.

On the first page application is shown the images and details for describe the mushrooms.
After providing all detail and push button submit, application is redirecting to the second page with the result if the mushroom is eatable or not.

### __pycache__ folder
* contains server execution components

### src folder
* contains flask application services and controllers files

    #### controllers folder
    * contains flask application main controller file  

    #### services folder
    * contains ML data mapper file
    
    #### models folder
    * contains the models in pickle format

### static folder
* contains flask application images and styles files

### templates folder
* contains using in application html pages: index, from and results files

### dependencies.py
* contains binder MushroomsDataMapper function code

### server.py
* contains falsk application server code
