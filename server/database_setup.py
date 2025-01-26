import sqlite3

def create_connection(db_file):
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(f"Connected to {db_file}")
    except sqlite3.Error as e:
        print(e)
    return conn

def create_table(conn, create_table_sql):
    try:
        c = conn.cursor()
        c.execute(create_table_sql)
    except sqlite3.Error as e:
        print(e)

def main():
    database = "shared_central_database.db"

    sql_create_python_table = """ CREATE TABLE IF NOT EXISTS python (
                                        id integer PRIMARY KEY,
                                        name text NOT NULL,
                                        code text NOT NULL
                                    ); """

    sql_create_javascript_table = """ CREATE TABLE IF NOT EXISTS javascript (
                                        id integer PRIMARY KEY,
                                        name text NOT NULL,
                                        code text NOT NULL
                                    ); """

    sql_create_other_table = """ CREATE TABLE IF NOT EXISTS other (
                                        id integer PRIMARY KEY,
                                        name text NOT NULL,
                                        code text NOT NULL
                                    ); """

    conn = create_connection(database)

    if conn is not None:
        create_table(conn, sql_create_python_table)
        create_table(conn, sql_create_javascript_table)
        create_table(conn, sql_create_other_table)
    else:
        print("Error! Cannot create the database connection.")

if __name__ == '__main__':
    main()
