from handler import Handler
class SnsHandlerProxy(Handler):
    def supports(self):
        if isinstance(self.get('Records', None), list):
            for record in self['Records']:
                if record.get('EventSource', None) is not 'aws:sns':
                    return False
            return True
        return False

    def payloads(self):
        sns_handlers = []
        payloads = []
        for handler_class in handlers:
            handler = handler_class(event, channel=self.channel, channel2=self.channel2)
            if handler.supports():
                payloads.extend(handler.payloads())
                do_fallback = False
        if do_fallback:
            payloads.extend(SnsFallbackHandler(event, channel=self.channel_fallback).payloads())
        return payloads


