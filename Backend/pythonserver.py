#https://flask.palletsprojects.com/en/3.0.x/


from flask import Flask, render_template
import CanvasBackend

app = Flask(__name__)

@app.route("/")
def hello_world():
    return render_template('SampleHtml.html')
    