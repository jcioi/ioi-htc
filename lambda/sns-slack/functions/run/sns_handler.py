class SnsHandler():
    def __init__(self, message, channel, channel2=None, channel_fallback=None):
        self.message = message
        self.channel = channel
        self.channel2 = channel2
        self.channel_fallback = channel2

    def detail(self):
        return self.event['detail']

    def supports(self):
        return False

    def payloads(self):
        return []


