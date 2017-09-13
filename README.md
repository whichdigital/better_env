# About

Better Environment (better_env) makes configuring your application easier. It imports environment configuration, parses `.env` files similar to the `dotenv` gem and adds extra configurability for each variable through the `config/better_env.yml` file.
Using the gem you can be sure that your application is started with all configuration necessary, and all the values are formatted for you under ```BetterEnv[:SOME_VARIABLE_NAME]```.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'better_env'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install better_env


## Usage

Add the configuration for parsing in `config/better_env.yml`.

```yaml
# <app_root>/config/better_env.yml
HOST:
  type: :url
  default: https://some-website.co.uk
```

Then add a `.env` file with application configuration in it:
```
# <app_root>/.env
HOST=https://other-host.co.uk
```

Or simply configure your environment:
```
$ export HOST=https://other-host.co.uk
$ <start application>
```

Additionaly you can pass a hash structure as configuration and array of `.env` files to read.
```
BetterEnv.load({ ... }, [ ... ])
```

**Note:** Keep in mind that environment configuration take precedence over `.env` files, after that the last parsed file has precedence.

## Usage with Rails

If you're using Rails, there's a railtie which will load the gem for you in a `before_configuration` block. Otherwise you can load it yourself by calling:
```ruby
BetterEnv.load
```

The YAML configuration file expects a different structure, namespaced by environments:
```yaml
development:
  HOST:
    type: :url
    default: https://development.some-website.co.uk
test:
  HOST:
    type: :url
    default: https://test.some-website.co.uk
production:
  HOST:
    type: :url
    default: https://some-website.co.uk

```

## Configuration in better_env.yml

Configuration for parsing the `.env` files should sit in `config/better_env.yml`. It consists of the variable name and all it's options in YAML format.
You can specify the type of the value (`boolean, integer, minutes, path, url`), if it's required and a default value. Any variables that are without configured type will be strings.

```ruby
  'boolean' # will return always true or false
  'integer' # always cast with .to_i
  'minutes' # cast to integer in seconds
  'path'    # string with no leading or trailing slashes
  'url'     # string with no trailing slash
  'symbol'  # always cast with .to_sym
  'string'  # this is the default, if you don't supply a type
```

Examples:

```yaml
DEVELOPMENT_MODE:
  type: boolean
  default: false

NUMBER_OF_INSTANCES:
  type: integer

CACHE_TIMEOUT:
  type: minutes

ASSETS_PATH:
  type: path
  required: true

ROOT_URL:
  type: url
  default: http://some-website.co.uk

CAPYBARA_JAVASCRIPT_DRIVER:
  default: chrome
  type: symbol
```

## Development

better_env uses [combustion](https://github.com/pat/combustion) and [appraisal](https://github.com/thoughtbot/appraisal) gems to test usage with the Rails framework. You can run all specs (including Rails specific) against Rails 4 and 5 with the following command:

```ruby
bundle exec appraisal install
bundle exec appraisal rspec
```

## Contributing

1. Clone it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Check if it passes green with rspec and latest rubocop and fasterer
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request with label "ready for review"
7. Contact one of the maintainers ([Evgeni Spasov](https://github.com/evgenispasov-which) or [Vasil Gochev](https://github.com/vasil-gochev))
