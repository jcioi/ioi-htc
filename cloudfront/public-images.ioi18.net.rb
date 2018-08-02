distribution "EHY9B446H8L32" do
  aliases do
    quantity 1
    items ["public-images.ioi18.net"]
  end
  default_root_object ""
  origins do
    quantity 1
    items do |*|
      id "S3-ioi18-public-images-eu"
      domain_name "ioi18-public-images-eu.s3.amazonaws.com"
      origin_path ""
      custom_headers do
        quantity 0
      end
      s3_origin_config do
        origin_access_identity ""
      end
    end
  end
  default_cache_behavior do
    target_origin_id "S3-ioi18-public-images-eu"
    forwarded_values do
      query_string false
      cookies do
        forward "none"
      end
      headers do
        quantity 0
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
    default_ttl 31536000
    max_ttl 31536000
    compress false
    lambda_function_associations do
      quantity 0
    end
    field_level_encryption_id ""
  end
  cache_behaviors do
    quantity 0
  end
  custom_error_responses do
    quantity 0
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
    acm_certificate_arn "arn:aws:acm:us-east-1:550372229658:certificate/e969d45d-23d7-456c-807c-cec432ec8771"
    ssl_support_method "sni-only"
    minimum_protocol_version "TLSv1.1_2016"
    certificate "arn:aws:acm:us-east-1:550372229658:certificate/e969d45d-23d7-456c-807c-cec432ec8771"
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
