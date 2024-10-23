import os
from dotenv import load_dotenv
import boto3
import psycopg2

load_dotenv()

def get_ssm_parameter(name):
    ssm = boto3.client('ssm', region_name=os.getenv('AWS_REGION', 'us-east-1'))
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

if __name__ == "__main__":
    main()