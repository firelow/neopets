neopets
=======
Help Lena get some paint brushes!

### Installation
* `gem install bundler`
* `bundle install`
* If running in Chrome, download the [chromedriver](http://chromedriver.storage.googleapis.com/index.html) (version >= 2.8) and drop it somewhere in your PATH.

### Running
* `bundle exec ruby get_neopoints.rb`

### Neopet Requirements
* Have a bank account
* Access to the Lab Ray (TODO, make optional)
* Account must be at least 48 hours old.

### Debugging
For breakpoints, make sure your config.yml file has the `debugger: true` option
set.  In addition to that, use the function `break(...)` to add breakpoints in
the code.
