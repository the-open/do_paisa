class Auth0Controller < ApplicationController
  def callback
    session[:userinfo] = request.env['omniauth.auth']

    # Redirect to the URL you want after successful auth
    redirect_to '/admin'
  end

  def failure
    @error_type = request.params['error_type']
    @error_msg = request.params['error_msg']
    render body: 'Uhh, something went wrong.', status: 403
  end

  def login
    session['omniauth.state'] = SecureRandom.hex(24)
    render '/login', layout: false
  end

  def logout
    reset_session
    redirect_to logout_url.to_s
  end
end
