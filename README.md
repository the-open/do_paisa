# DoPaisa

DoPaisa is a payment processor microservice that handles all the backend required for accepting payments.

DoPaisa's name originates from India, where it was ideated, and built. Do means two or give, and paisa is the smallest currency in India, and also means money. So DoPaisa translates to Give Money or Two Cents.

## Features:

* Multiple payment processors
* Recurring Payments
* One Click Donation Support


## Payment Processors:

* Stripe

## Dev Install
1. `git clone https://github.com/the-open/do_paisa.git`
1. `cd do_paisa`
1. `bundle install`
1. `cp .env.sample .env`
1. `createdb do_paisa_dev`
1. Add `DATABASE_URL=postgres://localuser:password@localhost:5432/do_paisa_dev` to the `.env` file
1. `foreman run rails db:schema:load`
1. `foreman start` 

Your app should be running on `localhost:3000`

You also need to configure Auth0 for the dev setup to fully work. 
1. Create an Auth0 account and then create a new "Web Client" on https://manage.auth0.com.
1. Add your local development domain to the "Allowed web origins" e.g. `http://localhost:3000`
1. Add the callback URL to the "Allowed callback URLs" `http://localhost:3000/auth/auth0/callback`
1. Under 'Advanced settings', change "OIDC Conformant" toggle to off (and save)
1. Add the Auth0 credentials for Client ID, Secret and Domain to your .env file
1. Restart the app and navigate to `/admin/login` and it should load.

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
