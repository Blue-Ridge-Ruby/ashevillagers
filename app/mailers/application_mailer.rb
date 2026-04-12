class ApplicationMailer < ActionMailer::Base
  include Configuration::Configurable

  configure_with from: :email_from
  default from: from # use `mail(from:)` in mailer methods, too, since the default is loaded at app boot and may have changed

  layout "mailer"
end
