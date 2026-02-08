# Ashevillagers

Community platform for Asheville, built with Rails and Svelte.

## Stack

- **Ruby** 3.4.1 / **Rails** 8.1.2
- **SQLite3** (database, cache, queue, cable)
- **Vite** with TailwindCSS 4 and Svelte 5
- **Solid Cache**, **Solid Queue**, **Solid Cable**

## Setup

```sh
bin/setup
bin/rails db:seed
```

`bin/setup` runs `bundle install`, `npm install`, database creation, and migrations.

The seed creates a default admin steward: `mayor@blueridgeruby.com` / `password`.

## Development

Start all processes (Rails server, Vite dev server, Solid Queue):

```sh
bin/dev
```

The app runs at http://localhost:3000.

### Processes (Procfile.dev)

| Process | Command |
|---------|---------|
| web | `bin/rails server -p 3000` |
| vite | `bin/vite dev` |
| jobs | `bin/jobs` |

## Tests

```sh
bin/rails test
```

## Admin (Town Hall)

The admin area lives at `/town_hall`. Stewards are admin users who can:

- Sign in at `/town_hall/session/new`
- Manage other stewards at `/town_hall/stewards`
- Reset passwords via email

### Key routes

| Path | Description |
|------|-------------|
| `/town_hall/session/new` | Sign in |
| `/town_hall/stewards` | Manage stewards |
| `/town_hall/password_reset/new` | Request password reset |

### Mail in development

Emails open in the browser automatically via [letter_opener](https://github.com/ryanb/letter_opener).

## Deployment

Deployed with [Kamal](https://kamal-deploy.org). See `config/deploy.yml`.
