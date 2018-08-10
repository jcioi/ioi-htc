from handler import Handler
class CodePipelineHandler(Handler):
    def is_pipeline(self):
        return self.event.get('detail-type') == 'CodePipeline Pipeline Execution State Change'
    def is_stage(self):
        return self.event.get('detail-type') == 'CodePipeline Stage Execution State Change'
    def is_action(self):
        return self.event.get('detail-type') == 'CodePipeline Action Execution State Change'

    def supports(self):
        return self.is_pipeline() or self.is_action() or self.is_stage()

    def pipeline_name(self):
        return self.detail()['pipeline']

    def stage_name(self):
        return self.detail()['stage']

    def action_name(self):
        return self.detail()['action']

    def execution_id(self):
        return self.detail()['execution-id']

    def pipeline_url(self):
        return 'https://console.aws.amazon.com/codepipeline/home?region=%s#/view/%s' % (self.event['region'], self.pipeline_name())

    def pipeline_channel(self):
        if self.event.get('slack_channel'): # debug
            return self.event['slack_channel']
        if self.pipeline_name().startswith('ioi18-task-'):
            return self.channel2
        return self.channel

    def payloads(self):
        if self.is_stage():
            return []
        if self.is_action() and self.detail()['state'] == 'STARTED':
            return []

        attachment = None
        if self.is_pipeline():
            attachment = {
                'fallback': '%s %s' % (self.pipeline_name(), self.detail()['state']),
                'text': '<%s|%s> *%s*' % (self.pipeline_url(), self.pipeline_name(), self.detail()['state']),
                'mrkdwn_in': ['text'],
            }
        if self.is_action():
            action_name = ('%s (%s)' % (self.stage_name(), self.action_name())) if self.stage_name() != self.action_name() else self.stage_name()
            attachment = {
                'fallback': '%s %s: %s' % (self.pipeline_name(), action_name, self.detail()['state']),
                'text': '<%s|%s> %s: *%s*' % (self.pipeline_url(), self.pipeline_name(), action_name, self.detail()['state']),
                'mrkdwn_in': ['text'],
            }

        if attachment is not None:
            state_colors = {
                    'RESUMED': 'warning',
                    'CANCELED': 'warning',
                    'FAILED': 'danger',
                    'SUCCEEDED': 'good',
            }
            color = state_colors.get(self.detail()['state'], None)
            if color is not None:
                attachment['color'] = color

            attachment['footer'] = self.execution_id()

        payload = {
            'channel': self.pipeline_channel(),
            'username': 'AWS CodePipeline',
            'icon_emoji': ':potable_water:',
            'attachments': [attachment]
        }
        return [payload]


