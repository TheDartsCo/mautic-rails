Mautic::Engine.routes.draw do
  get :authorize, to: 'connections#authorize'
  get :oauth2, to: 'connections#oauth2'
end
