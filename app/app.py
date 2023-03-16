from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>This is a Hello World application</p>"

@app.route("/bio")
def hello_abc():
    return "<a href='https://tw.bionime.com/msg/about.html'>華廣生技首頁</a>"

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)