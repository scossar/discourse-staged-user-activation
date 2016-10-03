# name: staged-user-activation-email
# about: don't send an activation email to staged users that have been created through the api
# version: 0.1
# authors: scossar

after_initialize do

  UserActivator::EmailActivator.class_eval do
    def activate
      email_token = user.email_tokens.unconfirmed.active.first
      email_token = user.email_tokens.create(email: user.email) if email_token.nil?

      unless user.staged
        Jobs.enqueue(:critical_user_email,
                     type: :signup,
                     user_id: user.id,
                     email_token: email_token.token
        )
        I18n.t("login.activate_email", email: Rack::Utils.escape_html(user.email))
      end
    end
  end

end
