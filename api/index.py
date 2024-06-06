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



#fetch all doctors
@app.route('/doctor.get')
def api_item_get(): 
   response = supabase.table('doctor').select("*").execute()
   return json.dumps(response.data)

#fetch doctor status
@app.route('/doctor_status.get')
def api_doctor_status_get(): 
   id_doctor = request.args.get('id_doctor')
   response = supabase.table('doctor').select('account_status').eq('id_doctor', id_doctor).execute()
   return json.dumps(response.data)

# update doctor status
@app.route('/doctor_status.update')
def api_update_doctor_status(): 
    id_doctor = request.args.get('id_doctor')
    status = request.args.get('status')
    error = False

    if not error:
        response = supabase.table('doctor').update({'account_status': status}).eq('id_doctor', id_doctor).execute()
        print(str(response.data))
        if len(response.data) == 0:
            error = 'Error updating status to Accepted'

    if error:
        return json.dumps({'status': 500, 'message': error})

    return json.dumps({'status': 200, 'message': '', 'data': response.data})

#fetch all requests
@app.route('/requests.get')
def api_requests_get():
   id_user = request.args.get('id_user')
   status = request.args.get('status')
   error = False
   if not id_user:
        error = 'id_user parameter is required.'
   if not error:
        response = supabase.table('consultationrequest').select("pid, did, status, report, completiontime, patient: patient(name, phone, gender, birthDate, email, picture),"
                                                                "searchHistory: searchHistory(symptoms), consultationPrice: consultationPrice(type, price)").eq('did',id_user ).eq('status',status ).execute()
        return json.dumps(response.data)

#fetch consultation types and prices
@app.route('/consultation_prices.get')
def api_consultation_prices_get():
   id_doctor = request.args.get('id_doctor')
   error = False
   if not id_doctor:
        error = 'id_doctor parameter is required.'
   if not error:
        response = supabase.table('consultationPrice').select("id, type, price").eq('id_doctor',id_doctor ).execute()
        return json.dumps(response.data)

# update status from suspended to Accepted
@app.route('/toAccepted.update')
def api_update_to_accepted(): 
    did = request.args.get('doctor_id')
    pid = request.args.get('patient_id')
    error = False

    if not error:
        response = supabase.table('consultationrequest').update({'status': 'accepted'}).eq('did', did).eq('pid', pid).eq('status', 'suspended').execute()
        print(str(response.data))
        if len(response.data) == 0:
            error = 'Error updating status to Accepted'

    if error:
        return json.dumps({'status': 500, 'message': error})

    return json.dumps({'status': 200, 'message': '', 'data': response.data})

# update status from suspended to Cancelled
@app.route('/toCancelled.update')
def api_update_to_cancelled(): 
    did = request.args.get('doctor_id')
    pid = request.args.get('patient_id')
    error = False

    if not error:
        response = supabase.table('consultationrequest').update({'status': 'cancelled'}).eq('did', did).eq('pid', pid).execute()
        print(str(response.data))
        if len(response.data) == 0:
            error = 'Error updating status to Cancelled'

    if error:
        return json.dumps({'status': 500, 'message': error})

    return json.dumps({'status': 200, 'message': '', 'data': response.data})

# update status to rejected
@app.route('/toRejected.update')
def api_update_to_rejected(): 
    did = request.args.get('doctor_id')
    pid = request.args.get('patient_id')
    error = False

    if not error:
        response = supabase.table('consultationrequest').update({'status': 'rejected'}).eq('did', did).eq('pid', pid).execute()
        print(str(response.data))
        if len(response.data) == 0:
            error = 'Error updating status to Rejected'

    if error:
        return json.dumps({'status': 500, 'message': error})

    return json.dumps({'status': 200, 'message': '', 'data': response.data})

# update status from accepted to completed
@app.route('/toCompleted.update')
def api_update_to_completed(): 
    did = request.args.get('doctor_id')
    pid = request.args.get('patient_id')
    error = False

    if not error:
        response = supabase.table('consultationrequest').update({'status': 'completed'}).eq('did', did).eq('pid', pid).eq('status', 'accepted').execute()
        print(str(response.data))
        if len(response.data) == 0:
            error = 'Error updating status to completed'

    if error:
        return json.dumps({'status': 500, 'message': error})

    return json.dumps({'status': 200, 'message': '', 'data': response.data})

# add consultation 
@app.route('/consultation.add')
def api_update_add_consultation(): 
    did = request.args.get('doctor_id')
    pid = request.args.get('patient_id')
    report = request.args.get('report')
    completionTime = request.args.get('completionTime')
    selectedConsultation = request.args.get('selectedConsultation')
    error = False

    if not error:
        response = supabase.table('consultationrequest').update({'status':'completed','report': report, 'completiontime': completionTime, 'consultationPrice_id': selectedConsultation}).eq('did', did).eq('pid', pid).eq('status', 'accepted').execute()
        print(str(response.data))
        

    if error:
        return json.dumps({'status': 500, 'message': error})

    return json.dumps({'status': 200, 'message': '', 'data': response.data})

@app.route('/ConsultationHistory.get')
def get_consultation_history():
    try:
        patient_id = request.args.get('patient_id')
        # Querying the consultation request table with the specific patient ID
        consultation_query = supabase.table('consultationrequest').select('report','docs','search_id','did').eq('pid', patient_id).execute()
        
        # Filter consultation results based on search_id not being None
        filtered_results = [record for record in consultation_query.data if record['search_id'] is not None]
        
        # Initialize a list to hold combined results
        combined_results = []
        
        # Iterate through each filtered result from the consultation request
        for consultation in filtered_results:
            search_id = consultation.get('search_id')
            did = consultation.get('did')  # Get the doctor ID from the consultation record
            
            # Query the searchHistory table based on the search_id
            search_query = supabase.table('searchHistory').select('symptoms','result','created_at').eq('search_id', search_id).execute()
            
            # Query the doctor table based on the doctor ID (did)
            doctor_query = supabase.table('doctor').select('name', 'phone').eq('id_doctor', did).execute()
            
            # If there is data in the searchHistory and doctor queries, combine with consultation record
            if search_query.data and doctor_query.data:
                # Combine the consultation record with the corresponding searchHistory record and doctor's name and phone number
                combined_results.append({
                    'consultation': consultation,
                    'searchHistory': search_query.data[0],  # Assuming each search_id has a unique record
                    'doctor': doctor_query.data[0]  # Assuming each did has a unique record
                })
        
        # Check if there are combined results
        if combined_results:
            return json.dumps({'status': 200, 'message': '', 'data': combined_results})
        else:
            # Return a message if no combined records were found
            return json.dumps({'status': 404, 'message': 'No consultation history found for the specified patient ID'})
    
    except Exception as e:
        # Handle exceptions
        return json.dumps({'status': 500, 'message': f'An error occurred: {str(e)}'})

#signup

import re
@app.route('/user.signup', methods=['GET', 'POST'])
def api_users_signup():
    print("hi")
    email = request.args.get('email')
    password = request.args.get('password')
    name = request.args.get('name')
    phone = request.args.get('phone')
    gender = request.args.get('gender')
    birthdate = request.args.get('birthdate')
    speciality = request.args.get('speciality')
    diploma = request.args.get('diploma')
    image = request.args.get('image')
    pronum = request.args.get('pronum')
	


    error = False

    # Email validation with regex
    if not email or not isinstance(email, str) or (not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email)):
        error = 'Email format is invalid'

    # Password validation
    if (not error) and ((not password) or (len(password) < 5)):
        error = 'Provide a password'

    
    

    if not error:
        response = supabase.table('doctor').select("*").ilike('email', email).execute()
        if len(response.data) > 0:
            error = 'User already exists'
            return json.dumps({'status': 400, 'message': error})
    print("before insertion")
    # Inserting into 'user' table
    user_insertion = supabase.table('doctor').insert({"name": name, "email": email, "password": password, "gender": gender, "phone": phone, "birthDate": birthdate, "speciality": speciality, "diploma": diploma, "proNum": pronum, "picture": image}).execute()
    print("after insertion")

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
       response = supabase.table('doctor').select("*").ilike('email', 
											email).eq('password',password).execute()

       if len(response.data)>0:
           return json.dumps({'status':200,'message':'','data':response.data})
             
   if not error:
        error='Invalid Email or password'
  
   return json.dumps({'status':500,'message':error})



# Update user profile
@app.route('/user.update_profile', methods=['POST', 'GET'])  
def api_user_update_profile():    
    user_id = request.args.get('id_doctor')  
    name = request.args.get('name')    
    email = request.args.get('email')  
    phone = request.args.get('phone')  
    birthdate = request.args.get('birthdate')
    gender = request.args.get('gender')
    error = False  
    # Add your validation logic here if needed  
    # if not user_id:        error = 'User ID is required.'  
    if not error:  
        try:           
            # Example: Your Supabase API endpoint for updating user profile  
            response = supabase.table('doctor').update({                
                'name': name,  
                'email': email,                
                'phone': phone, 
                'gender': gender,
                'birthDate': birthdate, 
            }).eq('id_doctor', user_id).execute()  
            if len(response.data) == 0:                
                error = 'Error updating user profile.'  
        except Exception as e:            
            error = f'Unexpected error occurred: {e}'  
    # Return JSON response  
    if error:        
        return json.dumps({'status': 500, 'message': error})  
    return json.dumps({'status': 200, 'message': 'User profile updated successfully'})





@app.route('/update.doctor.location', methods=['GET', 'POST'])
def update_doctor_location():
    
    id_doctor =  request.args.get('id_doctor')
    latitude = request.args.get('latitude')
    longitude = request.args.get('longitude')
    
    # Update doctor location in Supabase

    error =False
    if (not error):   
        response = supabase.table('doctor').update(
            {'latitude': latitude, 'longitude': longitude}
        ).match({'id_doctor': id_doctor}).execute()
        print(str(response.data))
        if len(response.data)==0:
            error='Error adding location'       
    if error:
        return json.dumps({'status':500,'message':error})       
    
    return json.dumps({'status':200,'message':'','data':response.data})








if __name__ == '__main__':
    app.debug = True
    app.run()