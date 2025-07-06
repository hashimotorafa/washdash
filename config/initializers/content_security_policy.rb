# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none

  # Allow CoreUI CDN
  policy.style_src   :self, :https, "'unsafe-inline'", "https://cdn.jsdelivr.net"
  policy.script_src  :self, :https, "'unsafe-inline'", "https://cdn.jsdelivr.net"

  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# Generate session nonces for permitted importmap and inline scripts
Rails.application.config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }

# Report violations without enforcing the policy.
# Rails.application.config.content_security_policy_report_only = true
