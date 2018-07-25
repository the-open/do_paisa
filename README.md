# DoPaisa

DoPaisa is a payment processor microservice that handles all the backend required for accepting payments.

DoPaisa's name originates from India, where it was ideated, and built. Do means two or give, and paisa is the smallest currency in India, and also means money. So DoPaisa translates to Give Money or Two Cents.

## Features:

* Multiple payment processors
* Recurring Payments
* One Click Donation Support


## Payment Processors:

* Stripe

## Table of contents

-   [Installation Steps](#installation-steps)
-   [Contributing](#contributing)

## Installation Steps:

1. Clone the repo.

```
git clone git@github.com:the-open/do_paisa.git
```

1. Make sure you have `ruby 2.4.1` with `bundle`.
If you have trouble installing 2.4.1,  see [this gist](https://gist.github.com/mattantonelli/71a45e8acfe442f86158598297845233)

1.`bundle install`

1.`bundle exec rails db:create`

1.`bundle exec rails db:schema:load`

1.`bundle exec rails s`


This will start your server at localhost://3000/admin

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
