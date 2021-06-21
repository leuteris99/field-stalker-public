import datetime

class Package:
    """ The main form of the data that will be stores in the db. """
    def __init__(self, id, ard_id, temp, light, humidity, timestamp):
        """ 
        The main form of the data that will be stores in the db.
            Parameters:
                id: the id of the package,
                ard_id: the id of the arduino that this package origins from,
                temp: temperature that was recorded,
                light: the light that was recorded,
                humidity: the humidity that was recorded,
                timestamp: the date and time of the creation of the package (in 'datetime' data type).
        
        """
        self.id = id
        self.ard_id = ard_id
        self.temp = temp
        self.light = light
        self.humidity = humidity
        if isinstance(timestamp, int):
            self.timestamp = datetime.datetime.fromtimestamp(timestamp, datetime.timezone.utc)
        else:
            self.timestamp = timestamp

    def __str__(self) -> str:
        return '{' + str(self.id) + ', ' + str(self.ard_id) + ', ' + str(self.temp) + ', ' + str(self.light) + ', ' + str(self.humidity) + ', ' + str(self.timestamp) + ' }'