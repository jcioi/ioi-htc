from handler import Handler
import json
class FallbackHandler(Handler):
    def supports(self):
        return True

    def payloads(self):
        return [{
            'channel': self.channel,
            'username': 'AWS (fallback)',
            'text': "```\n%s\n```" % json.dumps(self.event, indent=2, sort_keys=True),
            'mrkdwn': True,
            'fallback': json.dumps(self.event),
        }]



