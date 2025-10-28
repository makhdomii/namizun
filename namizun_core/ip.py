from namizun_core import database
from random import choice, randint

cache_ip_list = {}

def get_random_range_ip_from_database():
    # Treat each non-empty, non-comment line as a literal IP
    lines = database.get_cache_parameter('range_ips').split('\n')
    candidates = [line.strip() for line in lines if line.strip() and not line.strip().startswith('#')]
    return choice(candidates) if candidates else ''


def get_random_ip_from_database():
    selected = get_random_range_ip_from_database()
    parts = selected.split('.') if selected else []
    if (
        len(parts) == 4 and
        all(p.isdigit() for p in parts) and
        0 <= int(parts[0]) <= 255 and
        0 <= int(parts[1]) <= 255 and
        0 <= int(parts[2]) <= 255 and
        0 <= int(parts[3]) <= 255
    ):
        return selected
    else:
        # Fallback to a random-like valid IP if list is empty or invalid entry picked
        return f"{randint(1, 254)}.{randint(0, 255)}.{randint(0, 255)}.{randint(1, 254)}"


def get_game_port():
    return choice([3478, 28960, 27014, 27020, 25565, 27015, 3724, 5000])


def cache_ip_ports_from_database():
    global cache_ip_list
    cache_ip_list = database.get_ip_ports_from_database()


def get_random_ip_port():
    if len(cache_ip_list) > 0:
        target_ip, target_port = choice(list(cache_ip_list.items()))
        del cache_ip_list[target_ip]
    else:
        target_ip = get_random_ip_from_database()
        target_port = get_game_port()
        database.set_ip_port_to_database(target_ip, target_port)
    return target_ip, target_port
