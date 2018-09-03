# -*- mode: ruby -*-
# vi: set ft=ruby :
distribution "EK1FB8RNBZBI8" do
  aliases do
    quantity 0
  end
  default_root_object ""
  origins do
    quantity 1
    items do |*|
      id "Custom-ranking-prd-origin.ioi18.net"
      domain_name "ranking-prd-origin.ioi18.net"
      origin_path ""
      custom_headers do
        quantity 0
      end
      custom_origin_config do
        http_port 80
        https_port 443
        origin_protocol_policy "https-only"
        origin_ssl_protocols do
          quantity 1
          items ["TLSv1.2"]
        end
        origin_read_timeout 60
        origin_keepalive_timeout 5
      end
    end
  end
  default_cache_behavior do
    target_origin_id "Custom-ranking-prd-origin.ioi18.net"
    forwarded_values do
      query_string false
      cookies do
        forward "none"
      end
      headers do
        quantity 2
        items ["Accept", "Host"]
      end
      query_string_cache_keys do
        quantity 0
      end
    end
    trusted_signers do
      enabled false
      quantity 0
    end
    viewer_protocol_policy "redirect-to-https"
    min_ttl 0
    allowed_methods do
      quantity 2
      items ["GET", "HEAD"]
      cached_methods do
        quantity 2
        items ["GET", "HEAD"]
      end
    end
    smooth_streaming false
    default_ttl 0
    max_ttl 10
    compress true
    lambda_function_associations do
      quantity 0
    end
    field_level_encryption_id ""
  end
  cache_behaviors do
    quantity 1
    items do |*|
      path_pattern "/events"
      target_origin_id "Custom-ranking-prd-origin.ioi18.net"
      forwarded_values do
        query_string false
        cookies do
          forward "none"
        end
        headers do
          quantity 3
          items ["Accept", "Host", "Last-Event-ID"]
        end
        query_string_cache_keys do
          quantity 0
        end
      end
      trusted_signers do
        enabled false
        quantity 0
      end
      viewer_protocol_policy "redirect-to-https"
      min_ttl 0
      allowed_methods do
        quantity 2
        items ["GET", "HEAD"]
        cached_methods do
          quantity 2
          items ["GET", "HEAD"]
        end
      end
      smooth_streaming false
      default_ttl 86400
      max_ttl 31536000
      compress false
      lambda_function_associations do
        quantity 1
        items do |*|
          lambda_function_arn "arn:aws:lambda:us-east-1:550372229658:function:cms-rankingwebserver-sse-preprocess_last_event_id:14"
          event_type "viewer-request"
        end
      end
      field_level_encryption_id ""
    end
  end
  custom_error_responses do
    quantity 2
    items do |*|
      error_code 500
      response_page_path ""
      response_code ""
      error_caching_min_ttl 10
    end
    items do |*|
      error_code 502
      response_page_path ""
      response_code ""
      error_caching_min_ttl 10
    end
  end
  comment ""
  logging do
    enabled false
    include_cookies false
    bucket ""
    prefix ""
  end
  price_class "PriceClass_All"
  enabled true
  viewer_certificate do
    acm_certificate_arn "arn:aws:acm:us-east-1:550372229658:certificate/08b9bfd8-dc7c-4997-9ed8-82c24b99d34c"
    ssl_support_method "sni-only"
    minimum_protocol_version "TLSv1.1_2016"
    certificate "arn:aws:acm:us-east-1:550372229658:certificate/08b9bfd8-dc7c-4997-9ed8-82c24b99d34c"
    certificate_source "acm"
  end
  restrictions do
    geo_restriction do
      restriction_type "none"
      quantity 0
    end
  end
  web_acl_id ""
  http_version "http2"
  is_ipv6_enabled true
end
