from handler import Handler
class CodeBuildHandler(Handler):
    def is_build_state(self):
        return self.event.get('detail-type') == 'CodeBuild Build State Change'

    def supports(self):
        return self.is_build_state()

    def project_name(self):
        return self.detail()['project-name']

    def build_arn(self):
        return self.detail()['build-id']
    def build_id(self):
        return self.build_arn().split('/')[-1]

    def build_url(self):
        return 'https://console.aws.amazon.com/codebuild/home?region=%s#/builds/%s/view/new' % (self.event['region'], self.build_id())

    def build_status(self):
        return self.detail()['build-status']

    def current_phase(self):
        return self.detail()['current-phase']

    def from_codepipeline(self):
        return self.detail().get('source', {}).get('type', None) == 'CODEPIPELINE'

    def build_channel(self):
        if self.event.get('slack_channel'): # debug
            return self.event['slack_channel']
        if self.project_name().startswith('ioi18-cmstask'):
            return self.channel2
        return self.channel

    def payloads(self):
        if self.from_codepipeline():
            return []

        attachment = None
        if self.is_build_state():
            attachment = {
                'fallback': '%s %s' % (self.build_id(), self.build_status()),
                'text': '<%s|%s> %s' % (self.build_url(), self.project_name(), self.build_status()),
                'mrkdwn_in': ['text'],
            }

        if attachment is not None:
            state_colors = {
                    'STOPPED': 'warning',
                    'FAILED': 'danger',
                    'SUCCEEDED': 'good',
            }
            color = state_colors.get(self.build_status(), None)
            if color is not None:
                attachment['color'] = color

            attachment['footer'] = self.build_id()

        payload = {
            'channel': self.build_channel(),
            'username': 'AWS CodeBuild',
            'icon_emoji': ':wheelchair:',
            'attachments': [attachment]
        }
        return [payload]


