import package as p
import firebase_admin
from firebase_admin import credentials, firestore

def establishConnection():
    """ 
    Establishing a connection between this script and the firebase firestore db.
        Returns:
            client: an instance that referce to the db. (Inside the collection "package")
     """
    cred = credentials.Certificate("./serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    client = db.collection('package')
    print("connected")
    return client

def createData(data, client):
    """ 
    Creates a new entry to the db.
        Parameters:
            client: reference to the db,
            data: a 'Package' object that will be send to the db to get stored.
        Returns:
            res: if successfull it will return a timestamp with the time of the operations completion.
    """
    res = client.document(str(data.id)).set(vars(data))
    return res

def readAllData(client):
    """
    Reads all the entries in the db. (Inide the collection "package")
        Parameters:
            client: reference to the db. 
        Return:
            res: A list that contains all the entries in the form of the "Package" object.
    """
    docs = client.stream()
    res = list()
    for doc in docs:
        tmp = doc.to_dict()
        # print(tmp)
        res.append(p.Package(doc.id, tmp['ard_id'], tmp['temp'], tmp['light'], tmp['humidity'], tmp['timestamp']))
    return res
