"use strict";

exports.handle = (event, context, callback) => {
  let request = event.Records[0].cf.request;

  const uri = request.uri;
  console.log(`uri: ${request.uri}`)
  if (!uri) {
    callback(null, request);
    return;
  }

  const lastEventIdQueryMatch = request.querystring.match(/([;&]|^)last_event_id=(.+?)([;&]|$)/);
  console.log(`querystring: ${request.querystring}`);
  if (lastEventIdQueryMatch) {
    console.log(`match: ${lastEventIdQueryMatch}`);
    if (request.headers['last-event-id']) {
      console.log(`last-event-id header exists`);
    } else {
      console.log(`last-event-id set to ${lastEventIdQueryMatch[2]}`);
      request.headers['last-event-id'] = [{
        'key': 'last-event-id',
        'value': lastEventIdQueryMatch[2],
      }];
    }
    console.log(`headers: ${JSON.stringify(request.headers)}`);
    request.querystring = request.querystring.replace(/([;&]|^)last_event_id=(.+?)([;&]|$)/g, '$1$3').replace(/;;|&&/g, '');
    console.log(`querystring: ${request.querystring}`);
  }

  callback(null, request);
  return;
}

