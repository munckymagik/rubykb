# My Ruby Knowledge Base

My personal notebook of examples demonstrating the features of the
Ruby language, made in the form of Rspec specifications.

It is really just a reference for me, it is not intended to be a
thorough spec (for that see http://rubyspec.org/).

As and when I experiment with any particular feature, this repo
will provide me a place to capture what I learn.

## Testing Ruby type checking

```shell
$ bundle exec steep check
test_fodder.rb:11:15: ArgumentTypeMismatch: receiver=singleton(::TestFodder), expected=::String, actual=::Integer (123)
```
