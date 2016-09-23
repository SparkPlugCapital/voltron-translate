[![Build Status](https://travis-ci.org/ehainer/voltron-translate.svg?branch=master)](https://travis-ci.org/ehainer/voltron-translate)

# Voltron::Translate

Voltron Translate is a different, in my mind more logical way of dealing with internationalization in rails, largely inspired by the Magento framework's __() method.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voltron-translate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install voltron-translate

Then run the following to create the voltron.rb initializer (if not exists already) and add the translate config:

    $ rails g voltron:translate:install

## Usage

Voltron Translate extends ActiveRecord::Base, ActionController::Base, and ActionView::Base with a __ (double underscore) method that makes internationalization and/or translating static phrases easier.

Once installed, from any class that extends from any of the three rails classes you can use the double underscore method to allow for real time text translation. For example:

```ruby
@user = User.new(user_params)

if @user.save
  redirect_to @user, notice: __("User has been saved successfully.")
else
  flash.now[:alert] = __("User could not be saved.")
  render :new
end
```

or to use interpolation to support dynamic phrases:

```ruby
@user = User.new(user_params)

if @user.save
  redirect_to @user, notice: __("User with name %{person_name} has been saved successfully.", person_name: @user.name)
else
  flash.now[:alert] = __("User with name %{person_name} could not be saved.", person_name: [user_params[:first_name], user_params[:last_name]].join(" "))
  render :new
end
```

If the value of `Voltron.config.translate.enabled` is `true` and the code was running under one of the environments specified in `Voltron.config.translate.build_environment` (default: "development") then the line of text will be written to a each locale file you've configured. i.e. - If `Voltron.config.translate.locales == [:en, :es, :de]` then the phrase will be written to en.csv, es.csv, de.csv

## Translating

To translate a phrase, you only need to open the locale file you wish to translate the text for and change the value in the second column. For example, given en.csv with the following contents:

```
"User with name %{person_name} has been saved successfully.","User with name %{person_name} has been saved successfully."
```

Changing it to this:

```
"User with name %{person_name} has been saved successfully.","Welcome, %{person_name}! You're all ready to go."
```

Will cause any instance of `__("User with name %{person_name} has been saved successfully.", person_name: "Carl")` to output `Welcome, Carl! You're all ready to go.`

Note that if a phrase does not exist in the CSV, you can always add it manually just so long as it matches exactly the text contained within the first argument of a __("") method. Voltron Translate uses `Voltron.config.translate.build_environment` to determine what environments it's allowed to auto-generate translations for, but it only writes to locale files whenever a __() is actually reached. Consider:

```ruby
if 1 == 1
  __("Hello World")
else
  __("Goodbye World")
end
```

In a case like the above, "Goodbye World" will never be written to any locale file. If you still want to translate that phrase however you can just add the following to the csv:

```
"Goodbye World","Goodbye World, nice to know ya."
```

Then consider changing your if condition to something a little less absurd so that code could be reached.

## Choosing a translation locale

By default, the file Voltron Translate will pull the translations from is determined by the value of `I18n.locale` If you set the value to `:de` it will look for translations in de.csv

If you need a specific __() call to use a specific locale, you may specify it as the second argument:

```ruby
__("User with name %{person_name} has been saved successfully.", :de, person_name: @user.name)
```

Will always look for the above translation within de.csv

## Development
Welcome, %{person_name}! You're all ready to go.
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ehainer/voltron-translate. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

