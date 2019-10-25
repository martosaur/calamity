![Calamity](calamity.png)
# Calamity
## Dead simple json storage service for your test accounts

## What is it
Sometimes when doing integration testing you just can't create accounts on every run. Calamity is a service that you can deploy to your infrstracture and use as a shared storage for all your test account.

## How it looks like
An account is just an arbitrary json really. You can:

Create an account
```
POST http://calamity:4000/api/v1/accounts
{
    "data": {
        <your custom data here>
    },
    "id": 1,
    "locked": false,
    "locked_at": null,
    "name": "my account"
}
```
Search an account by word
```
POST http://calamity:4000/api/v1/accounts/search?search=value
```
Or search by json
```
POST http://calamity:4000/api/v1/accounts/search
{
	"search": {
		"option": "value"
	}
}
```
Create pool
```
POST http://calamity:4000/api/v1/pools/
{
	"pool": {
		"name": "my pool"
	}
}
```
Add account to pool
```
PUT http://calamity:4000/api/v1/pools/<pool_id>/accounts/<account_id>
```
Lock account from pool
```
POST http://calamity:4000/api/v1/pools/<pool_id>/lock?lock_for=300
```
Unlock account if you don't need it anymore:
```
POST http://calamity:4000/api/v1/accounts/<account_id>/unlock
```

## Locking
Sharing test accounts is all good and fun until several tests decide to run on the same account simultaniously. You can avoid this by using locking mechanism. Group accounts in pools and then lock random account from a pool whenever you need to. Don't forget to unlock it after you're done.

Locked accounts got unlocked automatically every 3600 seconds. You can alter this setting using `CALAMITY_UNLOCK_AFTER` variable.

## Authorization #security
Service requires `Authorization: Bearer <token>` header to authorize requests. Just provide token as `CALAMITY_AUTH_TOKEN` environmental variable for service.

## Development

To get started:

  * [Install Elixir 1.9.0](https://elixir-lang.org/install.html)
  * Checkout this repo
  * Install dependencies with `mix deps.get`
  * Spin up a postgres DB and put credentials into `config/dev.exs` and `config/test.exs`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Run tests using `mix test`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you have Calamity running on `localhost:4000`

## Productionish deployment
Build docker image with:
```
docker build -t calamity .
```
Then you can run the container. Make sure to specify `PORT`, `CALAMITY_AUTH_TOKEN` and `DATABASE_URL` environmental variables:
```
docker run -p 4000:4000 -e "PORT=4000" -e "CALAMITY_AUTH_TOKEN=helloworld" -e "DATABASE_URL=postgres://postgres:postgres@host.docker.internal:5432/calamity_dev" -e "CALAMITY_LIVE_VIEW_SALT=5wJx/wmaNdguKacShUSjCpcNY7gt/nEG" calamity:latest
```

---

[Picture source](https://www.deviantart.com/wandrevieira1994/art/Random-Drawing-19-Calamity-789830146)