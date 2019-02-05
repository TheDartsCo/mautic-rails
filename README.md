# Mautic-Redis rails
A fork from [activo-inc fork's][activo-inc fork] from [luk4s code][luk4s code] which is
RoR helper / wrapper for Mautic API and forms. But it is using Redis instead of DB to store the credentials.

## Why a fork from a fork?
- The original code is DB dependent, you must create a table called `mautic_connections` in your DB.
- The original code has some routes and views which is not a good idea to expose.
- The `activo-inc fork's` has some good enhancements and additions.

## Then, what's the difference in this fork?
- Added Redis integration to save the tokens.
- Removed `some` un-needed files (i.e. assets).
- Removed views and un-needed controller methods.
- Followed RuboCop in some recommendations.

## Usage
### Install
Add this line to your application's Gemfile:

```ruby
gem 'mautic-redis', github: 'TheDartsCo/mautic-redis-rails'
```

### Configure
  1. Create Mautic Oauth2 API.
  3. Create `config/initializers/mautic.rb` and fill in your credentials.
```ruby
Mautic.configure do |config|
  # Mautic URL
  config.mautic_url = 'https://mautic.my.app'
  # Public Key
  config.public_key = 'public_key'
  # Secret Key
  config.secret_key = 'secret_key'
  # Redis Connection Config
  config.redis_config = { url: 'redis://127.0.0.1:6379' }
end
```

  3. Add to `config/routes.rb`
```ruby
mount Mautic::Engine => '/mautic'
```

### Use
  1. Create Mautic Oauth2 API
  2. Store the API Public Key and Secret Key in `mautic.rb` initializer file
  3. Authorize it by visiting `your-website-url/mautic/authorize`
  4. Then to use it in your app,
 
  ```ruby
  m = Mautic::Connection.last
  ```
  Get specify contact:
  ```ruby
  contact = m.contact.find(1) # => #<Mautic::Contact id=1 ...>
  ```
  Collections of contacts:
  ```ruby
  m.contacts.where("gmail").each do |contact|
    #<Mautic::Contact id=12 ...>
    #<Mautic::Contact id=21 ...>
    #<Mautic::Contact id=99 ...>
  end
  ```
  New instance of contacts:
  ```ruby
  contact = m.contacts.new({ email: "newcontactmail@fake.info"} )
  contact.save # => true
  ```
  Update contact
  ```ruby
  contact.email = ""
  contact.save # => false
  contact.errors # => [{"code"=>400, "message"=>"email: This field is required.", "details"=>{"email"=>["This field is required."]}}]
  ```
  Of course you can use more than contact: `assets`, `emails`, `companies`, `forms`, `points` ...
### Gem provides simple Mautic form submit [Not tested]
There are two options of usage:
  1. Use default mautic url from configuration and shortcut class method:
  ```ruby
    # form: ID of form in Mautic *required*
    # url: Mautic URL - default is from configuration
    # request: request object (for domain, and forward IP...) *optional*
    Mautic::FormHelper.submit(form: "mautic form ID") do |i|
      i.form_field1 = "value1"
      i.form_field2 = "value2"
    end
  ``` 
  2. Or create instance
  ```ruby
  # request is *optional*
  m = Mautic::FormHelper.new("https://mymautic.com", request)
  m.data = {} # hash of attributes
  m.push # push data to mautic 
  ```
  
### Webhook receiver [Not tested]
Receive webhook from mautic, parse it and prepare for use.

  1. add concern to your controller
      
          include Mautic::ReceiveWebHooks
  2. in routes must be specify `:mautic_id`, for example:
  
          post "webhook/:mautic_id", action: "webhook", on: :collection

## TODO 
- A lot of cleaning.
- Fix all tests.
- Make sure the forms and webhook are working.

## Contributing
Ideas and pull requests are welcome!

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[activo-inc fork]: https://github.com/activo-inc/mautic-rails
[luk4s code]: https://github.com/luk4s/mautic-rails
