# DoPaisa

DoPaisa is a payment processor microservice that handles all the backend required for accepting payments.

DoPaisa's name originates from India, where it was ideated, and built. Do means two or give, and paisa is the smallest currency in India, and also means money. So DoPaisa translates to Give Money or Two Cents.

## Features:

* Multiple payment processors
* Recurring Payments
* One Click Donation Support


## Payment Processors:

* Stripe

## Setup

* Use ruby 2.4.1
* `cp .env.sample .env.development`
* `bundle install`
* `bundle exec rails db:setup`
* `bundle exec rails s`
* Go to `/admin` and add a payment processor

# Contributing:

DoPaisa is an open source project and we encourage contributions. We feel that a welcoming community is important and we ask that you follow our [Code Of Conduct](https://github.com/the-open/do_paisa/blob/master/CODE_OF_CONDUCT.md) in all interactions with the community.

In the spirit of open source software, **everyone** is encouraged to help improve this project.

Here are some ways **you** can contribute:

* by reporting bugs
* by adding a new feature
* by adding support for a new payment processor
* by reviewing pull requests
* by writing or editing documentation

If you would like to add a new feature or a new payment processor, please create a new issue, and let us know what you're working on.

# License:

DoPaisa is released under [MIT License](https://github.com/the-open/do_paisa/blob/master/LICENSE).
