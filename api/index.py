from flask import Flask, request, jsonify
from flask import request
import json
from supabase import create_client, Client
from flask import jsonify
from datetime import datetime, timedelta,timezone
import asyncio
from geopy.distance import geodesic
import requests
import google.generativeai as genai




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


# Configure the API key
genai.configure(api_key="AIzaSyB-XMSt9qLoAomQAlPl8tmtuouTDHuU8oU")

def get_gemini_response(input_text, prompt):
    model = genai.GenerativeModel(model_name="gemini-1.0-pro-001")
    response = model.generate_content([input_text, prompt])
    return response.text

@app.route('/get_specialist', methods=['POST'])
def get_specialist():
    try:
        data = request.get_json()
        input_text = data.get('symptoms', '')

        if not input_text:
            return jsonify({"error": "No symptoms provided"}), 400

        prompt = (
            "Based on the given text, determine the appropriate specialist for the patient. "
            "Possible specialists include: Allergist, Pediatrician, Otolaryngologist, Orthopedist, Generalist. "
            "If none of these specialists are appropriate or if the symptoms are unclear, suggest to rewrite the symptoms they are not clear. "
            "Without too much explanation if there is any suggested specialty write it directly"
            "Text: "
        )

        # Call the function to get the response from the language model
        specialist = get_gemini_response(input_text, prompt)
        print(specialist)

        # List of valid specialists
        valid_specialists = ["Allergist", "Dermatologist", "Pediatrician", "Otolaryngologist", "Orthopedist", "Generalist"]

        # Check if the response is one of the valid specialists
        if specialist.capitalize() in valid_specialists:
            return jsonify({"specialist": specialist.capitalize()})
        else:
            return jsonify({"error": "An error occurred. We cannot analyze your input."}), 500

    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500



@app.route('/find_doctor', methods=['POST', 'GET'])
async def request_doctor():
    data = request.get_json()
    patient_id = data.get('patient_id')
    doctor_ids = data.get('doctor_ids')

    # Ensure data is valid
    if not patient_id or not doctor_ids:
        return jsonify({'message': 'Invalid request data'}), 400

    # Iterate through each doctor ID
    for doctor_id in doctor_ids:
        # Create a new consultation request in the database
        new_request = {
            'pid': patient_id,
            'did': doctor_id,
            'status': 'suspended'
        }
        supabase.table('consultationrequest').insert(new_request).execute()

        # Check for 30 seconds if the doctor accepts the request
        timeout = datetime.now(timezone.utc) + timedelta(seconds=30)

        while datetime.now(timezone.utc) < timeout:
            request_data = supabase.table('consultationrequest').select('*').eq('pid', patient_id).eq('did', doctor_id).execute().data

            if any(requesti['status'] == 'accepted' for requesti in request_data):
                # If a doctor accepted the request, return success message
                return jsonify({'message': f'Request accepted by doctor ID {doctor_id}'}), 200

            await asyncio.sleep(1)  # Wait for a second before checking again

        # If no doctor accepted the request within the timeout period, reject the request
        supabase.table('consultationrequest').update({'status': 'rejected'}).eq('pid', patient_id).eq('did', doctor_id).eq('status', 'suspended').execute()

    # If all doctors rejected the request
    return jsonify({'message': 'No doctors accepted the request'}), 200


#fetch all patients
@app.route('/patient.get')
def api_item_get(): 
   response = supabase.table('patient').select("*").execute()
   return json.dumps(response.data)




@app.route('/consultationStatus')
def consultation_status():
    # Get the request ID from the query parameters
    request_id = request.args.get('request_id')
    
    # Validate that the request_id is provided
    if not request_id:
        return jsonify({'status': 400, 'message': 'Missing request_id'})

    try:
        # Query the consultation request table using the request ID
        response = supabase.table('consultationrequest').select("pid, did, status, doctor:doctor(name)").eq('requestid', request_id).execute()

        # Check if the query returned any data
        if response.data:
            # Return the first result (assuming request ID is unique)
            request_data = response.data[0]
            return jsonify({
                'status': 200,
                'message': 'Consultation request found',
                'data': request_data
            })
        else:
            # No consultation request found for the given request ID
            return jsonify({
                'status': 404,
                'message': 'Consultation request not found'
            })
    
    except Exception as e:
        # Handle any exceptions that occur during the database query
        return jsonify({'status': 500, 'message': f'An error occurred: {str(e)}'})


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
    picture = request.args.get('picture')

    error = False

    # Email validation with regex
    if not email or not isinstance(email, str) or (not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email)):
        error = 'Email format is invalid'

    # Password validation
    if (not error) and ((not password) or (len(password) < 5)):
        error = 'Provide a password'
    

    if not error:
        response = supabase.table('patient').select("*").ilike('email', email).execute()
        if len(response.data) > 0:
            error = 'User already exists'
            return json.dumps({'status': 400, 'message': error})
    print("before insertion")
    # Inserting into 'user' table
    user_insertion = supabase.table('patient').insert({"name": name, "email": email, "password": password, "gender": gender, "phone": phone, "birthDate": birthdate, "picture": picture,}).execute()
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
       response = supabase.table('patient').select("*").ilike('email', 
											email).eq('password',password).execute()

       if len(response.data)>0:
           return json.dumps({'status':200,'message':'','data':response.data})
             
   if not error:
        error='Invalid Email or password'
  
   return json.dumps({'status':500,'message':error})



# Update user profile
@app.route('/user.update_profile', methods=['POST', 'GET'])  
def api_user_update_profile():    
    user_id = request.args.get('id_patient')  
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
            response = supabase.table('patient').update({                
                'name': name,  
                'email': email,                
                'phone': phone, 
                'gender': gender,
                'birthDate': birthdate, 
            }).eq('id_patient', user_id).execute()  
            if len(response.data) == 0:                
                error = 'Error updating user profile.'  
        except Exception as e:            
            error = f'Unexpected error occurred: {e}'  
    # Return JSON response  
    if error:        
        return json.dumps({'status': 500, 'message': error})  
    return json.dumps({'status': 200, 'message': 'User profile updated successfully'})







@app.route('/getDoctors', methods=['GET'])
def api_get_doctors():
    # Get the 'specialty' query parameter
    specialty = request.args.get('specialty')

    # Get the patient's latitude and longitude from the query parameters
    patient_latitude = request.args.get('latitude')
    patient_longitude = request.args.get('longitude')

    try:
        # Start with a base query for doctors
        doctor_query = supabase.table('doctor').select('id_doctor', 'name', 'speciality', 'phone', 'latitude', 'longitude')

        # Add filters for accepted and account_status
        doctor_query = doctor_query.eq('accepted', True).eq('account_status', True)
        
        # Add a filter for specialty if provided
        if specialty:
            doctor_query = doctor_query.eq('speciality', specialty)
        
        # Execute the doctor query
        doctors_result = doctor_query.execute()
        
        # Check if no doctors are found
        if not doctors_result.data:
            return jsonify({
                'status': 404,
                'message': 'No doctors found for the given specialty',
                'data': []
            }), 404

        # Iterate over the doctors and calculate the distance from the patient
        doctors_with_distances_and_prices = []
        for doctor in doctors_result.data:
            doctor_latitude = doctor['latitude']
            doctor_longitude = doctor['longitude']
            # Calculate the distance between the patient and the doctor using geodesic
            distance = geodesic((patient_latitude, patient_longitude), (doctor_latitude, doctor_longitude)).meters
            doctor['distance'] = distance

            # Fetch the lowest consultation price for the doctor
            id_doctor = doctor['id_doctor']
            price_query = supabase.table('consultationPrice').select("price").eq('id_doctor', id_doctor).eq('type', 'basic')
            price_result = price_query.execute()

            if price_result.data:
                doctor['fee'] = price_result.data[0]['price']
            else:
                doctor['fee'] = None  # Or set a default value if no price is found
            
            doctors_with_distances_and_prices.append(doctor)

        # Sort the list of doctors by distance
        doctors_with_distances_and_prices.sort(key=lambda x: x['distance'])

        # Return the result as JSON
        return jsonify({
            'status': 200,
            'message': '',
            'data': doctors_with_distances_and_prices
        })
    except Exception as e:
        # Handle any exceptions that may occur
        return jsonify({
            'status': 500,
            'message': str(e),
            'data': []
        }), 500







@app.route('/getHistoryByPatient1/<id>')
def api_get_History1(id):
    searchHistory_query = supabase.from_('searchHistory').select("*").eq('patient_id', id)
    searchHistory_result = searchHistory_query.execute()

    return json.dumps({'status': 200, 'message': '', 'data': searchHistory_result.data})


@app.route('/requestConsultation', methods=['POST'])
def request_consultation():
    # Parse JSON data from the request
    data = request.get_json()
    patient_id = data.get('patient_id')
    doctor_id = data.get('doctor_id')
    
    # Validate the inputs
    if not patient_id or not doctor_id:
        return jsonify({'status': 400, 'message': 'Missing patient_id or doctor_id'})

    try:
        # Insert the consultation request into the consultationrequest table
        response = supabase.table('consultationrequest').insert({
            'pid': patient_id,
            'did': doctor_id,
            'status': 'suspended',
            'search_id': 3
        }).execute()
        
        # Check if the insertion was successful
        if len(response.data) == 0:
            return jsonify({'status': 500, 'message': 'Failed to create consultation request'})
        
        # Assuming `response.data` contains the inserted record data
        request_id = response.data[0]['requestid']  # Adjust 'id' to the appropriate field name
        
        # Return a success message with the request ID
        return jsonify({'status': 201, 'message': 'Consultation request created successfully', 'request_id': request_id})
    
    except Exception as e:
        # Return an error message if an exception occurs
        return jsonify({'status': 500, 'message': f'An error occurred: {str(e)}'})




@app.route('/getConsultationHistory/<patient_id>')
def get_consultation_history(patient_id):
    try:
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
            return jsonify({'status': 200, 'message': '', 'data': combined_results})
        else:
            # Return a message if no combined records were found
            return jsonify({'status': 404, 'message': 'No consultation history found for the specified patient ID'})
    
    except Exception as e:
        # Handle exceptions
        return jsonify({'status': 500, 'message': f'An error occurred: {str(e)}'})



@app.route('/update.patient.location', methods=['GET', 'POST'])
def update_patient_location():
    
    id_patient =  request.args.get('id_patient')
    latitude = request.args.get('latitude')
    longitude = request.args.get('longitude')
    
    # Update patient location in Supabase

    error =False
    if (not error):   
        response = supabase.table('patient').update(
            {'latitude': latitude, 'longitude': longitude}
        ).match({'id_patient': id_patient}).execute()
        print(str(response.data))
        if len(response.data)==0:
            error='Error adding location'       
    if error:
        return json.dumps({'status':500,'message':error})       
    
    return json.dumps({'status':200,'message':'','data':response.data})



















#here i am testing if it is working to work on it after tteh exams
@app.route('/accept_request', methods=['POST'])
def accept_request():
    # Hard-coded locations for testing
    doctor_location = [36.681495, 2.41461]  # Example coordinates
    patient_location = [36.687872, 2.420318]  # Example coordinates

    print(f"Doctor Location: {doctor_location}")
    print(f"Patient Location: {patient_location}")

    eta_minutes = calculate_eta(doctor_location, patient_location)

    # Hard-coded patient_id for testing
    patient_id = 123
    notify_patient(patient_id, eta_minutes)

    return jsonify({'status': 'accepted', 'eta': eta_minutes})

def calculate_eta(doctor_location, patient_location):
    api_key = '5b3ce3597851110001cf6248cd4c121a08db4762a8b947893ec1c26f'
    headers = {
        'Authorization': api_key,
        'Content-Type': 'application/json'
    }
    url = 'https://api.openrouteservice.org/v2/directions/driving-car'
    body = {
        "coordinates": [doctor_location, patient_location],
        "format": "json"
    }

    print(f"Requesting ETA with body: {body}")
    response = requests.post(url, json=body, headers=headers)
    print(f"Response Status Code: {response.status_code}")
    print(f"Response Body: {response.json()}")

    if response.status_code == 200:
        eta_seconds = response.json()['routes'][0]['summary']['duration']
        eta_minutes = eta_seconds // 60
        print(f"Calculated ETA in minutes: {eta_minutes}")
        return eta_minutes
    else:
        print(f"Failed to calculate ETA. Error: {response.text}")
        raise Exception('Failed to calculate ETA')

def notify_patient(patient_id, eta):
    print(f"Notifying patient ID {patient_id} with ETA {eta} minutes.")
    # Implementation for notifying the patient, e.g., using Supabase Realtime
    pass



if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0', port=5000)

