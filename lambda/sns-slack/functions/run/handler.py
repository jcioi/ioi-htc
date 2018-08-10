class Handler():
    def __init__(self, event, channel, channel2=None, channel_fallback=None):
        self.event = event
        self.channel = channel
        self.channel2 = channel2
        self.channel_fallback = channel2

    def detail(self):
        return self.event['detail']

    def supports(self):
        return False

    def payloads(self):
        return []


