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



#signup

import re
@app.route('/user.signup', methods=['GET', 'POST'])
def api_users_signup():
    email = request.args.get('email')
    password = request.args.get('password')
    name = request.args.get('name')
    phone = request.args.get('phone')
    gender = request.args.get('gender')
    birthDate = request.args.get('birthDate')

    error = False

    # Email validation with regex
    if not email or not isinstance(email, str) or (not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email)):
        error = 'Email format is invalid'

    # Password validation
    if (not error) and ((not password) or (len(password) < 5)):
        error = 'Provide a password'

    # Phone number validation with regex
    if (not error) and (not re.match(r'^(05|06|07)\d{8}$', phone)):
        error = 'Phone number format is invalid'

    if not error:
        response = supabase.table('user').select("*").ilike('email', email).execute()
        if len(response.data) > 0:
            error = 'User already exists'
            return json.dumps({'status': 400, 'message': error})

    # Inserting into 'user' table
    user_insertion = supabase.table('patient').insert({"name": name, "email": email, "phone": phone, "password": password, "gender": gender, "birthDate": birthDate,}).execute()
    print("douaa")

    # Check if the user insertion was successful
    if len(user_insertion.data) == 0:
        error = 'Error creating the user'
    else:
        # If user creation was successful, proceed to create auth
        print(str(email))
        auth_response = supabase.auth.sign_up({"email" : email, "password": password})
        if 'error' in auth_response:
            error = 'Error creating authentication'
        else:
            # Both user and auth creations were successful
            print("douaa")
            print(str(auth_response))
    if error:
        return json.dumps({'status': 500, 'message': error})

    # Assuming user creation was successful and no error occurred
    print("sucess")
    return json.dumps({'status': 200, 'message': '', 'data': user_insertion.data})



#login
@app.route('/users.login',methods=['GET','POST'])
def api_users_login():
   email= request.args.get('email')
   password= request.args.get('password')
   error =False
   if not email or not isinstance(email, str) or (not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email)):
       error='Email needs to be valid'
   if (not error) and ( (not password) or (len(password)<5) ):
       error='Provide a password'
   if (not error):
       response = supabase.table('user').select("*").ilike('email', 
											email).eq('password',password).execute()

       if len(response.data)>0:
           return json.dumps({'status':200,'message':'','data':response.data})
             
   if not error:
        error='Invalid Email or password'
  
   return json.dumps({'status':500,'message':error})

if __name__ == '__main__':
    app.debug = True
    app.run()