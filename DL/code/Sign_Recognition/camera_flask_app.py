import cv2
import datetime, time
import os
import numpy as np
import pandas as pd 
from flask import Flask, render_template, Response, request, redirect, flash
from threading import Thread
from werkzeug.utils import secure_filename
import tensorflow as tf 
from keras.preprocessing.image import load_img 
from keras.preprocessing.image import img_to_array
from keras.applications.imagenet_utils import preprocess_input, decode_predictions
from keras.models import load_model
from keras.preprocessing import image
from keras.models import model_from_json


global capture,rec_frame, grey, switch, rec, out 
capture=0
grey=0

switch=1
rec=0

# Make shots directory to save pics
try:
    os.mkdir('./static/images')
except OSError as error:
    pass

try:
    os.mkdir('./static/images')
except OSError as error:
    pass

# Files Upload
path = os.getcwd()
UPLOAD_FOLDER = os.path.join(path, 'static/images')
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg'])

# Instatiate flask app  
app = Flask(__name__, template_folder='./templates')
camera = cv2.VideoCapture(0)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.secret_key = "secret key"


def record(out):
    global rec_frame
    while(rec):
        time.sleep(0.05)
        out.write(rec_frame)
 
def gen_frames():  # Generate frame by frame from camera
    global out, capture,rec_frame
    while True:
        success, frame = camera.read() 
        if success:
            if(grey):
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            if(capture):
                capture=0
                now = datetime.datetime.now()
                p = os.path.sep.join(['shots', "shot_{}.png".format(str(now).replace(":",''))])
                cv2.imwrite(p, frame)
            if(rec):
                rec_frame=frame
                frame= cv2.putText(cv2.flip(frame,1),"Recording...", (0,25), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255),4)
                frame=cv2.flip(frame,1)
            try:
                ret, buffer = cv2.imencode('.jpg', cv2.flip(frame,1))
                frame = buffer.tobytes()
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
            except Exception as e:
                pass 
        else:
            pass

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def read_image(filename):
    # Load the image
    img = load_img(filename, grayscale=True,target_size=(28, 28))
    # Convert the image to array
    img = img_to_array(img)
    # Reshape the image into a sample of 1 channel
    img = img.reshape( 1,28, 28, 1)
    # Prepare it as pixel data
    img = img.astype('float32')
    img = img / 255.0
    return img

@app.route('/',methods=['GET', 'POST'])
def index():
    return render_template('index.html')
    
@app.route('/video_feed')
def video_feed():
    return Response(gen_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/requests',methods=['POST','GET'])
def tasks():
    global switch,camera
    if request.method == 'POST':
        if request.form.get('click') == 'Capture':
            global capture
            capture=1
        elif request.form.get('grey') == 'Grey':
            global grey
            grey=not grey
        elif request.form.get('upload') == 'Upload':
            return render_template('upload.html')
        elif  request.form.get('rec') == 'Start/Stop Recording':
            global rec, out
            rec= not rec
            if(rec):
                now=datetime.datetime.now() 
                fourcc = cv2.VideoWriter_fourcc(*'XVID')
                out = cv2.VideoWriter('vid_{}.avi'.format(str(now).replace(":",'')), fourcc, 20.0, (640, 480))
                # Start new thread for recording the video
                thread = Thread(target = record, args=[out,])
                thread.start()
            elif(rec==False):
                out.release()        
    elif request.method=='GET':
        return render_template('index.html')
    return render_template('index.html')



@app.route('/upload', methods=['POST', 'GET'])
def upload_file():
    if request.method == 'POST':
        # Check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            flash('No file selected for uploading')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            flash('File successfully uploaded')
            return redirect('/predict')
        else:
            flash('Allowed file types are: png, jpg, jpeg')
            return redirect(request.url)
    return render_template('upload.html')

@app.route("/predict", methods = ['GET','POST'])
def predict():
    if request.method == 'POST':
        file1 = request.files['file']
        filename1 = file1.filename
        file_path = os.path.join('static/images', filename1)
        file1.save(file_path)
        img = read_image(file_path)
                # Predict the class of an image

        json_file = open('model/best_model1.json', 'r')
        loaded_model_json = json_file.read()
        json_file.close()
        loaded_model = model_from_json(loaded_model_json)
            # load weights into new model
        loaded_model.load_weights("model/best_model1.h5")
        loaded_model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

        pred = loaded_model.predict(img)
        pred = np.argmax(pred,axis=1)


        alphabets = 'abcdefghijklmnopqrstuvwxyz'
        mapping_letter = {}

        for i,l in enumerate(alphabets):
            mapping_letter[l] = i
        mapping_letter = {v:k for k,v in mapping_letter.items()}

        return render_template('predict.html', sign = mapping_letter[pred[0]] ,user_image = file_path)
    return render_template('predict.html')



if __name__ == '__main__':
    app.run()
    
camera.release()
cv2.destroyAllWindows()     