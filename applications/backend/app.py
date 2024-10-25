import os
import boto3
import psycopg2
from flask import Flask, jsonify
from psycopg2 import sql

app = Flask(__name__)

def get_ssm_parameter(name):
    ssm = boto3.client('ssm', region_name=os.getenv('AWS_REGION', 'us-east-2'))
    response = ssm.get_parameter(Name=name, WithDecryption=True)
    return response['Parameter']['Value']

def main():
    username = get_ssm_parameter('/rds/db/identifier-db/superuser/username')
    password = get_ssm_parameter('/rds/db/identifier-db/superuser/password')
    db_host = os.getenv('DB_HOST') 
    db_name = os.getenv('DB_NAME', 'db_name')

    conn = psycopg2.connect(
        host=db_host,
        database=db_name,
        user=username,
        password=password
    )

    print("Connection Properties:")
    print(conn.get_dsn_parameters())

    cur = conn.cursor()
    cur.execute("SELECT version();")
    db_version = cur.fetchone()
    print("RDS Version:", db_version)

    cur.close()
    conn.close()

def get_db_credentials():
    username = get_ssm_parameter('/rds/db/sonlh-db/superuser/username')
    password = get_ssm_parameter('/rds/db/sonlh-db/superuser/password')
    return username, password

@app.route('/info', methods=['GET'])
def info():
    try:
        # Retrieve environment variables
        db_host = os.getenv('DB_HOST') 
        db_name = os.getenv('DB_NAME', 'db_name')
        aws_region = os.getenv('AWS_REGION', 'us-east-2')
        
        # Get DB credentials
        db_username, db_password = get_db_credentials()
        
        # Connect to the PostgreSQL RDS instance
        conn = psycopg2.connect(
            host=db_host,
            database=db_name,
            user=db_username,
            password=db_password
        )
        
        # Get connection properties
        conn_props = conn.get_dsn_parameters()
        
        # Query to get PostgreSQL version
        cur = conn.cursor()
        cur.execute("SELECT version();")
        db_version = cur.fetchone()
        
        # Close connections
        cur.close()
        conn.close()
        
        # Prepare response
        response = {
            "connection_properties": conn_props,
            "rds_version": db_version[0]
        }
        
        return jsonify(response), 200
    
    except Exception as e:
        error_message = str(e)
        return jsonify({"error": error_message}), 500

if __name__ == "__main__":
    # Run the Flask app on all available IPs on port 80
    app.run(host='0.0.0.0', port=80)