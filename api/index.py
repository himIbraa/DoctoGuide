from flask import Flask, request
import json
from supabase import create_client, Client

app = Flask(__name__)

#This is the very stupid way to store private/confidential data inside GIT
#Store inside a file to be ignored
url="https://gkgupdxpofpowtfwcufj.supabase.co"
key="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrZ3VwZHhwb2Zwb3d0ZndjdWZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTMxMzM2NDcsImV4cCI6MjAyODcwOTY0N30.YQ1gz3dYcCVoA874jZDQ8-YPh02ib1wl1AWxZwQyXtE"
supabase: Client = create_client(url, key)

@app.route('/')
def home():
    return 'Hello, World!'

@app.route('/about')
def about():
    return 'About'



#fetch all patients
@app.route('/patient.get')
def api_item_get(): 
   response = supabase.table('patient').select("*").execute()
   return json.dumps(response.data)





if __name__ == '__main__':
    app.debug = True
    app.run()