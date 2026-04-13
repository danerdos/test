import mysql.connector

def get_connection():
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="d4n3r",
        database="bookapp"
    )
    return connection