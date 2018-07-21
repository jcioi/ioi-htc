vcl 4.0;

backend haproxy_elb_rproxy_s3 {
  .host = "127.0.0.1";
  .port = "10080";
  .first_byte_timeout = 10s;
  .connect_timeout = 3s;
  .between_bytes_timeout = 2s;
}

acl purge {
  "localhost";
  "127.0.0.1";
  "::1";
}

sub vcl_hash {
  if (req.http.host) {
    hash_data(req.http.host);
  } else {
    hash_data(server.ip);
  }
  hash_data(req.url);
}

sub vcl_recv {
  set req.backend_hint = haproxy_elb_rproxy_s3;

  if (req.url == "/httpd_alived") {
    return (synth(200, "OK " + server.identity));
  }

  if (req.http.host ~ "(?i)^cache\.") {
    set req.http.host = regsub(req.http.host, "(?i)^cache\.", "");
  } else {
    set req.http.host = "s3-apne1.ioi18.net";
  }

  if (req.method == "PURGE") {
    if (!client.ip ~ purge) {
      return (synth(403, "You're not allowed"));
    }
    return (purge);
  }

  if (req.method != "GET" && req.method != "HEAD") {
    return (pass);
  }

  if (req.http.Cookie) {
    return (pass);
  }
  if (req.http.Authorization) {
    return (pass);
  }

  return (hash);
}

sub vcl_hit {
  if (obj.ttl >= 0s) {
    return (deliver);
  }
  return (miss);
}

sub vcl_miss {
  return (fetch);
}

sub vcl_backend_response {
  if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503 || beresp.status == 504) {
    set beresp.ttl = 0s;
    set beresp.uncacheable = true;
    return (deliver);
  }
  if (beresp.status == 400 || beresp.status == 401 || beresp.status == 403 || beresp.status == 404) {
    set beresp.ttl = 0s;
    set beresp.uncacheable = true;
    return (deliver);
  }

  if (beresp.ttl <= 0s) {
    if (bereq.url ~ "(?i)/[^/]+cms-files-[^/]+/") {
      set beresp.ttl = 28800s;
    } else {
      set beresp.ttl = 300s;
    }
  }
  set beresp.grace = 3600s;
  return (deliver);
}


sub vcl_deliver {
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
  } else {
    set resp.http.X-Cache = "MISS";
  }
  set resp.http.X-Cache-Hits = obj.hits;
  set resp.http.X-Cache-Age = obj.age;
  set resp.http.X-Cache-Node = server.identity;

  return (deliver);
}
