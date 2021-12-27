import psycopg2
from datetime import datetime

settings = {
    'user': 'postgres',
    'password': 'qwerty123',
    'host': 'db',
    'port': 5432,
    'database': 'postgres'
}


def get_lidar():
    try:
        with psycopg2.connect(**settings) as conn:
            cur = conn.cursor()
            cur.execute('''select id, longitude, latitude, ts
                        from public.lidar''')
            data = cur.fetchall()
    except Exception as e:
        data = e

    return data


def add_coordinate(longitude, latitude):
    try:
        with psycopg2.connect(**settings) as conn:
            cur = conn.cursor()
            dt = datetime.now()
            cur.execute('''insert into public.lidar (ts, longitude, latitude)
                           values (%(ts)s, %(longitude)s, %(latitude)s)''',
                        {'ts': dt,
                         'longitude': longitude,
                         'latitude': latitude})
            conn.commit()
            data = True
    except Exception as e:
        data = e
    return data

def db_log(mode, move, dt, action):
    try:
        with psycopg2.connect(**settings) as conn:
            cur = conn.cursor()
            cur.execute("""insert into public.log (action, ts, param)
                           values (%(action)s, %(ts)s, %(param)s)""",
                        {'ts': dt,
                         'action': action,
                         'param': f"mode={mode};move={move}"})
            conn.commit()
            data = True
    except Exception as e:
        data = e
    finally:
        return data

def get_log():
    try:
        with psycopg2.connect(**settings) as conn:
            cur = conn.cursor()
            cur.execute('''SELECT "action", ts, param
                            FROM public.log
                            order by ts desc
                            limit 10;
                        ''')
            data = cur.fetchall()
    except Exception as e:
        data = e
    finally:
        return data

# print(db_log('left', 'auto', datetime.now(), 'change'))

# print(get_log())