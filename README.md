# Auto Shop SMS MVP

A dead-simple tool that lets a mechanic punch in a customer's name + phone, pick a status, and fire off a text. That's it. No database. No login. No bells. No whistles.

Built to validate one question: **will local shops actually use this?** If yes, then we layer features on. If no, we throw it away and we're out a weekend, not a quarter.

---

## What's in the box

```
auto-shop-sms/
├── backend/                  # Node + Express API (talks to Twilio)
│   ├── server.js             # Boots Express, mounts the route
│   ├── routes/
│   │   └── sendUpdate.js     # The one endpoint: POST /send-update
│   ├── utils/
│   │   ├── messageTemplates.js   # Status -> SMS body
│   │   └── validatePhone.js      # Loose phone-number sanity check
│   ├── .env.example          # Copy this to .env and fill in Twilio creds
│   └── package.json
│
├── frontend/                 # React (Vite) single-page app
│   ├── index.html
│   ├── vite.config.js
│   ├── package.json
│   └── src/
│       ├── main.jsx          # React entry point
│       ├── App.jsx           # Top-level layout
│       ├── App.css           # Minimal styling, no framework
│       ├── api.js            # fetch() wrapper for the backend
│       └── components/
│           └── StatusForm.jsx    # The form + send button + status messages
│
└── README.md                 # You are here
```

### Why each file exists

**Backend**

- `server.js` — Spins up Express, parses JSON, enables CORS so the React dev server (port 5173) can talk to it (port 3001). Mounts the route. That's its whole job.
- `routes/sendUpdate.js` — Receives `{ name, phone, status }`, validates, looks up the template, calls Twilio, returns success or error. One route to rule them all.
- `utils/messageTemplates.js` — Pure function that maps a status enum to the actual SMS text. Pulled out so future-you can edit copy without touching the route.
- `utils/validatePhone.js` — Strips formatting and checks we have something that vaguely resembles a US number. Twilio will reject garbage anyway, but failing fast gives a better error.
- `.env.example` — Template for the secrets file. The real `.env` is gitignored.

**Frontend**

- `main.jsx` — Vite/React boilerplate. Mounts `<App />` into `#root`.
- `App.jsx` — Page shell: header + form. Trivial right now; will grow if we add tabs/history.
- `StatusForm.jsx` — Where the actual work happens. Holds form state, handles submit, shows loading + result message. One component on purpose — easy to read top to bottom.
- `api.js` — Single `sendUpdate()` helper so components don't sprinkle `fetch` calls everywhere. Swap to axios or a real client later without touching components.
- `App.css` — Plain CSS. No Tailwind, no styled-components. The whole UI is one form.

---

## Local setup

You need **Node 18+** and a **Twilio account** (free trial works — they give you a sandbox number).

### 1. Get Twilio credentials

Sign up at https://twilio.com, then from the console copy:

- **Account SID**
- **Auth Token**
- **A Twilio phone number** (trial accounts get one free)

If you're on a trial account, Twilio will only let you text **verified** numbers. Verify your own cell first, then test with that.

### 2. Backend

```bash
cd backend
npm install
cp .env.example .env
# open .env and fill in your Twilio creds
npm run dev
```

Backend now running on `http://localhost:3001`.

### 3. Frontend

In a new terminal:

```bash
cd frontend
npm install
npm run dev
```

Frontend now running on `http://localhost:5173`.

### 4. Try it

Open the browser, type your verified phone number, pick a status, hit send. Phone should buzz within a few seconds.

---

## Future upgrade ideas (do NOT build these yet)

When real shops are using this and asking for more, here's the rough order to add things:

1. **Database (Postgres or SQLite)** — Once shops want a history of messages sent, or want to attach a vehicle/work order. Don't add it for "future-proofing" — add it when someone asks.
2. **Multi-shop / authentication** — When the second shop signs up. Magic-link login is enough; skip the OAuth circus.
3. **Templates editor in UI** — Let shops customize message copy without code.
4. **Two-way SMS** — Receive replies via Twilio webhook so customers can respond ("running late, can you hold it til 5?"). This is the killer feature once basic sends are working.
5. **Scheduled / delayed sends** — "Send 'ready for pickup' at 3pm." Cron job + a small queue.
6. **AI parsing** — Mechanic types `"john's civic is done, oil change $89"` and the system extracts customer + status + price. Big unlock for adoption — the form is the friction.
7. **Customer portal** — Customer clicks a link in the SMS, sees their work order, photos, line-item invoice.
8. **Payments** — Stripe link in the "Ready for Pickup" message so they can pay before walking in.

---

## What NOT to build yet

Resist these until a paying customer asks:

- ❌ User accounts / auth — no logins until you have more than one user
- ❌ Database — not needed if you're not persisting anything
- ❌ Tests — for an MVP this small, manual testing is faster
- ❌ TypeScript — JS is fine until the codebase actually hurts
- ❌ Docker / Kubernetes / CI / "production-ready" anything
- ❌ Admin dashboard, analytics, charts
- ❌ Mobile app — the web form on a phone browser is fine
- ❌ Custom domain, branded emails, fancy onboarding
- ❌ Roles, permissions, audit logs
- ❌ Internationalization
- ❌ A logo

---

## MVP-first philosophy

The point of this code is **not to be impressive**. It's to find out, this week, whether a shop owner will pay $50/mo to text customers more easily. Everything else is a distraction.

A few rules that keep this honest:

1. **Ship something a real person can use within a week.** If you've spent more than a week and nobody outside your house has touched it, you're building for yourself.
2. **Talk to 5 shops before writing any new feature.** If 4 of 5 don't ask for it, don't build it. Your gut is wrong more often than you think.
3. **Boring tech wins.** Express + React + Twilio is boring on purpose. Boring means fewer surprises and faster iteration.
4. **Optimize for delete-ability.** Every file you add is a file you might have to throw out. Add fewer of them.
5. **Hardcode until it hurts.** Status templates are hardcoded. Phone validation is naive. That's fine. You'll know exactly when it stops being fine, because someone will complain.
6. **Manual is fine.** No shop yet? Onboard them by texting the owner and adding their info to a config file. Don't build a sign-up flow before sign-ups exist.
7. **The product is the conversation, not the code.** The code is the cheapest part. Spend your time watching mechanics use it and asking what sucks.

When in doubt: do less.
