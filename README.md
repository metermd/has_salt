# has\_salt

You're using `has_secure_password`, right?  But sometimes, you still need a per-
record salt for other, non-password reasons.  For example, to generate non-
predictable URLs, secret URL's that aren't vulnerable to replayability, etc.

`has_salt` does all this for you, without having to do all the `before_validate`
dances, or make too many decisions regarding length, etc.

## Installation

Add this line to your application's Gemfile:

    gem 'has_salt', github: 'mieko/has_salt'

And then execute:

    $ bundle

## Usage

```ruby
class User < ActiveRecord::Base
  # defaults to column: :salt
  has_salt
end

```

## Alternate columns

You can specify the columns used as a salt:

```ruby
class Tenant < BaseTable
  has_salt column: :sodium
end
```

`has_salt` can be used on more than one column without conflicting, if you find
a need.

## Lengths

By default, has_salt tries to generate HasSalt::DEFAULT_LENGTH bytes of salt
data.  This can be overridden in a few ways:

  * Explicity passing `:length` or `:size` to `has_salt`
  * Applying length validations on the column.  `:is' will set it outright.
    `:minimum`, `:maximum` and `:in` options will adjust the default length
    to fit.
  * Schema information, for example, `:limit` on a column migration will
    adjust the default length to fit.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
