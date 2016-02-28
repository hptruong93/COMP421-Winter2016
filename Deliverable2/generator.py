import sys
import string
import random
import hashlib
import datetime

USER_COUNT = 1000
PAL_EVENT_MAX = 50
PAL_CORNER_MAX = 100

GROUP_COUNT = 100
STATUS_MAX = 100
PICTURE_MAX = 100
NOTIFICATION_MAX = 100
CONVERSATION_MAX = 50
MESSAGE_MAX = 100

WAVE_PROBABILITY = 0.5
FRIEND_PROBABILITY = 0.4
USER_PARTICIPATION_PROBABILITY = 0.2
PAL_EVENT_EDIT_PROBABILITY = 0.6
PAL_CORNER_EDIT_PROBABILITY = 0.7

user_ids = []
is_friend = {}
conversation_generated = 0

##############################################################################################################################
def random_string(size, chars=string.ascii_uppercase + string.ascii_lowercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

def random_len_string(max_size, chars=string.ascii_uppercase + string.ascii_lowercase + string.digits, min_size = 4):
    length = random.randint(min_size, max_size)
    return random_string(length, chars)

def random_choice(options = []):
    index = random.randrange(0,len(options))
    return options[index]

def random_boolean(p_true = 0.5):
    return True if random.random() < p_true else False

def random_date(start = datetime.datetime.now() - datetime.timedelta(days = 365), end = datetime.datetime.now()):
    """
    This function will return a random datetime between two datetime objects.
    """
    delta = end - start
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = random.randrange(int_delta)
    return start + datetime.timedelta(seconds=random_second)

##############################################################################################################################

def do_insert(name, fields, values):
    def _convert(data):
        if type(x) is str:
            return "'{0}'".format(x)
        elif type(x) is int:
            return str(x)
        elif type(x) is datetime.datetime:
            return "TIMESTAMP '{0}'".format(str(x))
        elif type(x) is bool:
            return 'TRUE' if x else 'FALSE'
        else:
            return str(x)

    print "INSERT INTO {0}({1}) VALUES ({2});".format(name, ', '.join(fields), ', '.join([_convert(x) for x in values]))

##############################################################################################################################

def users():
    def user():
        userid = random_len_string(50, min_size = 4)
        if userid in user_ids:
            return user()

        user_ids.append(userid)
        email = random_string(7) + '@' + random_choice(['gmail', 'yahoo', 'hotmail']) + '.com'
        salt = random_string(50)
        hash_value = hashlib.sha256(salt).hexdigest()

        return (userid, email, salt, hash_value)

    for i in xrange(USER_COUNT):
        current_user = user()
        do_insert('Users', ['userid', 'email', 'salt', 'password_hash'], current_user)

def user_profiles():
    for i in xrange(USER_COUNT):
        userid = user_ids[i]
        first_name = random_len_string(50)
        last_name = random_len_string(50)
        location = random_len_string(50)
        profile_picture_link = random_len_string(500, min_size = 100)
        owner = userid

        do_insert('UserProfiles', ['first_name', 'last_name', 'location', 'profile_picture_link', 'owner'], \
                            (first_name, last_name, location, profile_picture_link, owner))



def wave():
    for id1 in user_ids:
        for friend_id in is_friend[id1]:
            if random_boolean(WAVE_PROBABILITY):
                do_insert('Wave', ['userid_source', 'userid_destination', 'count'], [id1, friend_id, random.randrange(1, 2016)])

def groups():
    for i in xrange(GROUP_COUNT):
        current_group = (random_len_string(100), random_len_string(500))
        do_insert('Groups', ['group_name', 'description'], current_group)

def status_updates():
    for id_user in user_ids:
        limit = random.randrange(0, STATUS_MAX)
        for i in xrange(1, limit + 1):
            do_insert('StatusUpdates', ['content', 'time_stamp', 'location', 'owner'], \
                            (random_len_string(1000), random_date(), random_len_string(100), id_user))

def notifications():
    for id_user in user_ids:
        limit = random.randrange(0, NOTIFICATION_MAX)
        for i in xrange(1, limit + 1):
            do_insert('Notifications', ['type', 'time_stamp', 'content', 'owner'], \
                            (random_choice(['friend', 'corner', 'event']), random_date(), random_len_string(1000), id_user))

def pictures():
    for id_user in user_ids:
        limit = random.randrange(0, PICTURE_MAX)
        for i in xrange(1, limit + 1):
            do_insert('Pictures', ['caption', 'time_stamp', 'location', 'path_to_file', 'owner'], \
                            (random_len_string(500), random_date(), random_len_string(100), random_len_string(100), id_user))

def chat_conversations():
    global conversation_generated
    for id_user in user_ids:
        limit = random.randrange(0, CONVERSATION_MAX)
        for i in xrange(1, limit + 1):
            conversation_generated += 1
            do_insert('CharConversations', ['title', 'created_time', 'is_locked', 'initiator'], \
                            (random_len_string(50), random_date(), False, id_user))

def chat_messages():
    for id_user in user_ids:
        for conversation_id in xrange(1, conversation_generated + 1):
            if not random_boolean(USER_PARTICIPATION_PROBABILITY):
                continue

            do_insert('ConversationParticipation', ('userid', 'conversation'), (id_user, conversation_id))
            limit = random.randrange(0, MESSAGE_MAX)
            for i in xrange(1, limit + 1):
                do_insert('ChatMessages', ['created_time', 'content', 'conversation', 'owner'], \
                                (random_date(), random_len_string(500), random.randrange(1, conversation_generated) ,id_user))

###################################################################################
def friendship():
    for id1 in user_ids:
        for id2 in user_ids:
            if id1 >= id2 or not random_boolean(FRIEND_PROBABILITY):
                continue

            if id1 not in is_friend:
                is_friend[id1] = set()
            is_friend[id1].add(id2)
            if id2 not in is_friend:
                is_friend[id2] = set()
            is_friend[id2].add(id1)

            date = random_date()
            if random_boolean(0.9):
                status = 'friend'
            else:
                status = random_choice(('close_friend', 'spouse', 'parent', 'sibling'))

            do_insert('Friendship', ('first_person', 'second_person', 'start_date', 'status'), \
                            (id1, id2, date, status))
            do_insert('Friendship', ('first_person', 'second_person', 'start_date', 'status'), \
                            (id2, id1, date, status))


def pal_events():
    for userid in user_ids:
        limit = random.randrange(0, PAL_EVENT_MAX)
        for event_id in xrange(1, limit):
            do_insert('PalEvents', ['content', 'time_stamp', 'owner'], [random_len_string(1000), random_date(), userid])

            for friend_id in is_friend[userid]:
                if not random_boolean(PAL_EVENT_EDIT_PROBABILITY):
                    continue
                do_insert('PalEventEdits', ('editor', 'pal_event', 'time_stamp', 'changes'), (friend_id, event_id, random_date(), random_len_string(1000)))


def pal_corners():
    for userid in user_ids:
        limit = random.randrange(0, PAL_CORNER_MAX)
        for corner_id in xrange(1, limit):
            do_insert('PalCorners', ['type', 'description', 'created_time', 'owner'], \
                            [random_choice(['activity', 'book', 'movie', 'topic']), random_len_string(1000), random_date(), userid])

            for friend_id in is_friend[userid]:
                if not random_boolean(PAL_CORNER_EDIT_PROBABILITY):
                    continue
                do_insert('PalCornerEdits', ('editor', 'pal_corner', 'time_stamp', 'changes'), (friend_id, corner_id, random_date(), random_len_string(1000)))

def group_participation():
    for id_user in user_ids:
        for group_id in xrange(GROUP_COUNT):
            if random_boolean(USER_PARTICIPATION_PROBABILITY):
                do_insert('GroupParticipation', ('userid', 'group_id'), (id_user, group_id))

if __name__ == "__main__":
    def printerr(x):
        sys.stderr.write(x)
        sys.stderr.write('\n')

    printerr("Generating users")
    users()
    printerr("Generating profiles")
    user_profiles()
    printerr("Generating groups")
    groups()


    printerr("Generating statuses")
    status_updates()
    printerr("Generating notifications")
    notifications()
    printerr("Generating pictures")
    pictures()
    printerr("Generating chat conversations")
    chat_conversations()
    printerr("Generating messages")
    chat_messages()

    printerr("Generating friendship")
    friendship()
    printerr("Generating events")
    pal_events()
    printerr("Generating corners")
    pal_corners()
    printerr("Generating waves")
    wave()
