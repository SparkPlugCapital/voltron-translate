[![Coverage Status](https://coveralls.io/repos/github/ehainer/voltron-translate/badge.svg?branch=master)](https://coveralls.io/github/ehainer/voltron-translate?branch=master)
[![Build Status](https://travis-ci.org/ehainer/voltron-translate.svg?branch=master)](https://travis-ci.org/ehainer/voltron-translate)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

# Voltron::Translate

Voltron Translate is a different, in my mind more logical way of dealing with internationalization in rails, largely inspired by the Magento framework's `__()` helper method.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voltron-translate', '~> 0.2.1'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install voltron-translate

Then run the following to create the voltron.rb initializer (if not exists already), add the translate config, and generate the database migration:

    $ rails g voltron:translate:install

Then run the migrations to add the table to support backend translations:

    $ bundle exec rake db:migrate

## Usage

### The Double Underscore Method

Voltron Translate extends ActiveRecord::Base, ActionController::Base, ActionMailer::Base, and ActionView::Base with a __ (double underscore) method that makes internationalization and/or translating static phrases easier.

Once installed, from any class that extends from any of the four rails classes listed you can use the double underscore method to allow for text translation. For example:

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

### Backend Translations

To add support for translations of dynamic text, i.e. - Text entered into a form, Voltron Translate adds a `translates` class method to models.

```ruby
class Company < ActiveRecord::Base

  # translates :attribute_name1, :attribute_name2, :attribute_name3, ..., options={}
  translates :name, :greeting, { locales: [:en, :es, :de, :"en-GB"], default: :en }

end
```

Options to the `translates` method are optional, details of which are:

| Option  | Default                                                                                                                       | Comment                                                                                                                                                                                                                                                                            |
|---------|-------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| locales | `Voltron.config.translates.locales`, whose default is actually the value of `Rails.application.config.i18n.available_locales` | Should be an array of locale names, as strings or symbols. Each locale defined will extend the original attribute to make locale specific methods. i.e. - Locales `[:en, :es]` on attribute `name` would generate methods for `name_en`, `name_es`, `name_en=`, `name_es=`, etc... |
| default | nil                                                                                                                           | Should be a string or symbol of the default locale you'd like to use. This default overrides the value of `I18n.locale`, so should really only be used if the attribute in question needs to default to a different language.                                                      |

The `translates` method adds locale specific version of the attribute(s) to the model with the following methods:

`<attribute>_<locale>`

`<attribute>_<locale>=`

`<attribute>_<locale>?`

`<attribute>_<locale>_will_change!`

`<attribute>_<locale>_changed?`

`<attribute>_<locale>_was`

In addition, it will override the `<attribute>` method with one that takes a single, optional argument: the locale you want to return the text for. Consider the following:

```ruby
# Voltron.config.translate.locales = [:en, :es, :"en-GB"]
class Company < ActiveRecord::Base

  translates :name

end
```

```ruby
@company = Company.create(name: 'Company Name', name_es: 'Spanish Company Name', name_en_gb: 'British Company Name')

@company.name # Returns 'Company Name'
@company.name(:es) # Returns 'Spanish Company Name'
@company.name(:invalid_locale) # Returns 'Company Name', since it ultimately will fall back to the original attribute

# OR, access the locale directly:

@company.name_es # Returns 'Spanish Company Name'
@company.name_en_gb # Returns 'British Company Name'

# Without specifying a specific locale in either the method call or +translates+ option, it will try and base it's lookup by the value of I18n.locale

I18n.locale = :en
@company.name # Returns 'Company Name'

I18n.locale = :es
@company.name # Returns 'Spanish Company Name', since our global locale is set to :es
```

Should go without saying, but to set the translation text on the frontend, you'd just create a separate form field for each locales text:

```erb
<%= form_for @company do |f| %>
  
  <div>
    <%= f.label :name %>
    <%= f.text_field :name %>
  </div>

  <div>
    <%= f.label :name_es %>
    <%= f.text_field :name_es %>
  </div>

  <div>
    <%= f.label :name_en_gb %>
    <%= f.text_field :name_en_gb %>
  </div>

<% end %>
```

Add the appropriate attributes to your strong params, so on, so on...

## Caching

This gem relies on being able to cache translations for quicker lookup. While not a requirement, some sort of cache mechanism is highly recommended as you will notice a difference in page load time. Using [redis-rails](https://github.com/redis-store/redis-rails) or something similar is the most preferred method of caching, but even [FileStore](http://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-filestore) is better than nothing.

## Note

Setting `Voltron.config.translate.enabled` to `false` will never break any `__()` call, it simply causes it to ignore the locale argument (if specified) and return the interpolated string using the latter arguments (again, if any)

Disabling translations simply disables any IO related actions that would occur normally, like building or looking up translations when `__()` methods are called.

It also disables the locale specific text translation on any method call that was targeted with `translates`, meaning `@company.name(:es)` would be the equivalent of calling `@company.name`. Note that `@company.name_es` would still work as it normally would.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ehainer/voltron-translate. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.en.html).