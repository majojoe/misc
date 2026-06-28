from flask import Flask, jsonify
import psycopg2
import socket

app = Flask(__name__)

def create_db_connection():
    connection = psycopg2.connect(
        dbname="docker-compose-test",
        user="docker-testuser",
        password="9KJHd2A3_=)(23jkdsHJ",
        host="database"
    )
    return connection

@app.route('/')
def get_current_time():
    try:
        connection = create_db_connection()
        cursor = connection.cursor()
        
        cursor.execute("SELECT NOW()")
        current_time = cursor.fetchone()[0]

        cursor.close()
        connection.close()

        hostname = socket.gethostname()

        return f"Docker Container ID: {hostname}\nCurrent time from database: {current_time}"
    except psycopg2.Error as e:
        return jsonify(error=str(e)), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0')
