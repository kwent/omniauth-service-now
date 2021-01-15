![Ruby](https://github.com/kwent/omniauth-service-now/workflows/Ruby/badge.svg?branch=master)

# OmniAuth ServiceNow

This is the official OmniAuth strategy for authenticating to ServiceNow. To
use it, you'll need to sign up for an OAuth2 Client ID and Secret
on the [ServiceNow Developer Page](https://community.servicenow.com/community?id=community_blog&sys_id=56086e4fdb9014146064eeb5ca961957).

## Installation

```ruby
gem 'omniauth-service-now'
```

## Basic Usage

```ruby
use OmniAuth::Builder do
  provider :service_now, ENV['SERVICE_NOW_CLIENT_ID'], ENV['SERVICE_NOW_CLIENT_SECRET'], { scope: 'useraccount', client_options: { site: 'https://<instance-id>.service-now.com' } }
end
```

## Basic Usage Rails

In `config/initializers/service_now.rb`

```ruby
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :service_now, ENV['SERVICE_NOW_CLIENT_ID'], ENV['SERVICE_NOW_CLIENT_SECRET'], { scope: 'useraccount', client_options: { site: 'https://<instance-id>.service-now.com' } }
  end
```

## Dynamic client_id and client_secret (Cf. https://github.com/omniauth/omniauth/wiki/Setup-Phase)

In `config/initializers/service_now.rb`

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  setup_proc = lambda do |env|
    req = Rack::Request.new(env)
    env['omniauth.strategy'].options[:client_options][:site] = req.params['site']
    env['omniauth.strategy'].options[:client_id] = req.params['client_id']
    env['omniauth.strategy'].options[:client_secret] = req.params['client_secret']
  end
  provider :service_now, nil, nil, { setup: setup_proc, scope: 'useraccount' }
end
```

## Semver

This project adheres to Semantic Versioning 2.0.0. Any violations of this scheme are considered to be bugs.
All changes will be tracked [here](https://github.com/kwent/omniauth-service-now/releases).

## License

Copyright (c) 2021 Quentin Rousseau.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
