# Document Copilot — my learning checklist

This is our own version of the build checklist. It builds the same app as the tutorial, but every step also says **what to learn**, **who writes the code**, and **how to check you really understood it**.

Go top to bottom. A step is done when it works **and** you can answer its "Explain it back" questions in your own words. Finishing is not the goal; understanding is.

## How we work

Every step goes through the same loop:

1. **Plan:** Claude explains what we're building and why, in a few simple lines.
2. **Build:** the code gets written (see who writes it below).
3. **Explain:** Claude explains the code simply, with Flutter comparisons.
4. **Run:** you run it and see it work.
5. **Explain it back:** you answer the questions in your own words. Stuck? Ask again, differently.
6. **Commit:** one commit per step, with your own message.

**Who writes the code:**

- 🤖 **Claude writes**, you read it and ask "why" about anything unclear.
- 🤝 **You try first**, Claude fills the gaps.
- ✍️ **You write**, Claude reviews.

Rule of thumb: setup and plumbing are 🤖; the AI core is ✍️. Stuck on a ✍️ step? Say "write it" and Claude will, then explain it.

## The map

```text
0 Setup → 1 Python basics → 2 Backend + database → 3 Login → 4 Chat with fake answers
→ 5 Prepare the library ⭐ → 6 Search ⭐ → 7 AI answers ⭐ → 8 Trust UI
→ 9 Evals ⭐ → 10 Go live → 11 Portfolio
```

⭐ = AI engineering, the part you're here to master. Go slow there.

---

## Phase 0 — Setup

**Goal:** tools installed, accounts ready, filings downloaded.

- [x] 🤖 First git commit of the starter kit
- [x] ✍️ A test device ready: Red's iPad, paired with the Mac
- [x] ✍️ Create the Supabase project and save its keys somewhere safe ([guide](guides/supabase-setup.md))
- [x] ✍️ Create an OpenAI API key and set a small monthly spending limit in the OpenAI dashboard
- [x] ✍️ Put your name and email in `USER_AGENT` at the top of `data/download.py`, then run `uv run data/download.py`
- [x] ✍️ Open `data/downloads/manifest.json` and one downloaded filing in your browser

**Learn:**

- **10-K:** the yearly report every US public company must publish. It's our "library".
- **API key:** a password that lets your code use a paid service. Anyone who has it can spend your money.
- **`.env` file:** where secret keys live on your machine. It's in `.gitignore`, so it never reaches GitHub.

**Done when:** `manifest.json` lists about 25 filings for AAPL, MSFT, NVDA, AMZN and GOOGL.

**Explain it back:**

- Why must the OpenAI key never go into the Flutter app or into git?
- What's inside `manifest.json`, and why will it be useful later?

---

## Phase 1 — Python, just enough

**Goal:** read and write basic Python without fear. Practice in a `playground/` folder that we don't commit.

- [x] ✍️ Run your first script with `uv run hello.py`
- [x] 🤖 Set up Ruff in VS Code: formats Python on save (Python's `dart format`)
- [x] ✍️ Variables, `if`, `for`, f-strings (`f"Hello {name}"`)
- [x] ✍️ Lists and dicts (Python's `List` and `Map`)
- [x] ✍️ Functions with type hints (`def add(a: int, b: int) -> int:`)
- [x] ✍️ Classes, `@dataclass` and Pydantic `BaseModel` (Python's version of Dart model classes)
- [x] ✍️ `async` / `await` (same idea as Dart's `Future`)
- [x] ✍️ Imports, packages, `pyproject.toml` (Python's `pubspec.yaml`)
- [x] 🤝 Read `data/download.py` top to bottom and explain what each function does

**Learn:**

- **Indentation is the code.** Python uses 4 spaces where Dart uses `{ }`.
- **`None`, `True`, `False`** are Dart's `null`, `true`, `false`.
- **Type hints** (`name: str`) help you and your editor, but Python doesn't enforce them at runtime.
- **Pydantic** checks data at runtime. It's like `fromJson` that throws an error when a field is wrong.
- **`uv`** installs packages and runs Python, like `flutter pub get` and `flutter run` in one tool.

**Done when:** you can explain `data/download.py` line by line.

**Explain it back:**

- What's the difference between a list and a dict? What's each one called in Dart?
- What does `if __name__ == "__main__":` at the bottom of `download.py` do?

---

## Phase 2 — Backend + database

**Goal:** a running FastAPI server, and all tables created in Supabase.

- [x] 🤖 Install the backend packages (`uv add ...`, [guide](guides/backend-setup.md))
- [x] 🤖 `app/core/config.py`: reads settings from `.env` and stops the app at startup if one is missing
- [x] 🤝 `app/main.py`: the FastAPI app with a `GET /health` route (you write the route)
- [x] ✍️ Run the server, then open `http://localhost:8000/health` and `http://localhost:8000/docs`
- [x] 🤖 Database models, explained table by table: users, documents, chunks, chat threads, messages, citations
- [x] 🤖 Alembic setup and the first migration (pgvector, the embedding column, the full-text column, indexes, row-level security)
- [x] ✍️ Run `uv run alembic upgrade head`, then find your new tables in the Supabase dashboard
- [x] 🤖 `app/core/database.py`: the database clients

**Learn:**

- **Endpoint:** a URL your server answers. You've called hundreds with Dio; now you write them.
- **Decorator** (`@app.get("/health")`): a line above a function that registers it as an endpoint.
- **Table, row, column, primary key, foreign key:** how a database organizes data. A table is like a list of Dart model objects.
- **Migration:** a saved, step-by-step change to the database structure, like git history for your tables.
- **Index:** like the index at the back of a book. It makes search fast instead of reading every page.
- **pgvector:** a Postgres add-on that stores embeddings and finds the nearest ones.
- **Row-level security (RLS):** a database rule that each user sees only their own rows.

**Done when:** `/health` returns `{"status": "ok"}` and the tables show up in Supabase.

**Explain it back:**

- Why do we change tables through Alembic instead of clicking in the Supabase dashboard?
- Why do chunks need two indexes, one for vectors and one for full-text?
- What could go wrong without row-level security?

---

## Phase 3 — Login

**Goal:** sign up and sign in with email; the backend rejects requests without a valid token.

**Backend**

- [x] 🤝 `app/core/auth.py`: checks the token and returns the current user
- [x] 🤝 Return `401` when the token is missing or invalid

**Frontend**

- [ ] 🤖 Create the Flutter app in `frontend/` ([guide](guides/frontend-setup.md))
- [ ] ✍️ `core/config/env.dart` (reads `env.json`, fails fast) and Supabase init in `main.dart`
- [ ] ✍️ `core/network/api_client.dart`: Dio with an interceptor that adds the Supabase token
- [ ] ✍️ Sign-in and sign-up pages with an auth Cubit
- [ ] ✍️ Auth gate: send logged-out users to the sign-in page
- [ ] ✍️ Test it on your phone: sign up, sign in, call a protected endpoint

**Learn:**

- **JWT:** the login token. It's signed by Supabase, so nobody can fake or edit it.
- **`Authorization: Bearer <token>`:** the header that carries it. It's your ZERO.40 Dio interceptor again.
- **`401` vs `403`:** 401 means "who are you?" 403 means "I know who you are, but this isn't yours."
- **`Depends` in FastAPI:** gives each request what it needs (like the current user), a bit like get_it for one request.
- **`supabase_flutter`:** signs the user in and keeps the session on the device; the token it gives is what the backend checks.
- **`--dart-define-from-file`:** how Flutter reads `env.json` at build time, like your ZERO.40 `--dart-define` values.
- **`localhost` on a phone:** it means the phone itself, not your computer. Use your computer's Wi-Fi IP instead, like the `local` server in ZERO.40's `AppConfig`.

**Explain it back:**

- Why does the backend check the token with Supabase instead of trusting what the frontend says?
- When would you return 401, and when 403?

---

## Phase 4 — Chat with fake answers

**Goal:** the whole chat flow works end to end, with a fake reply streamed word by word.

**Backend**

- [ ] 🤖 Chat threads: list them, create one, load its history
- [ ] 🤝 `POST /chat/stream`: streams a fake reply word by word
- [ ] 🤖 Save the user's message and the reply after the stream ends
- [ ] 🤝 Return `403` when someone opens another user's thread

**Frontend**

- [ ] ✍️ Pages: chat list, one chat thread
- [ ] 🤝 Read the streamed answer with Dio (`ResponseType.stream`) and turn it into a Dart `Stream` in the chat repository
- [ ] ✍️ Chat Cubit, message list, input box, "typing" indicator
- [ ] ✍️ Test it: send a message, watch the fake reply stream in, reload, and the history is still there

**Learn:**

- **Streaming:** sending the answer in small pieces as it's made, like a Dart `Stream` or your Socket.IO chat.
- **`yield`:** Python's way to send one piece at a time from a function.
- **CRUD:** Create, Read, Update, Delete, the four basic things you do with data.
- **Fake data first:** proving the pipe works before adding AI, so later bugs are easier to find.

**Explain it back:**

- Why stream the answer instead of waiting for the full reply?
- What does `yield` do differently from `return`?

---

## Phase 5 — Prepare the library ⭐

**Goal:** every filing is cleaned, cut into chunks, turned into embeddings and saved.

- [ ] 🤖 The ingestion script's entry point
- [ ] 🤝 HTML → clean text (Markdown), keeping page and section info
- [ ] ✍️ Chunking: size plus overlap, with a label on each chunk (company, year, page, section)
- [ ] ✍️ Your first tests: chunking tests with `pytest`
- [ ] 🤖 Save one `source_documents` row per filing, using `manifest.json`
- [ ] ✍️ Create an embedding for each chunk with OpenAI and save it with the chunk
- [ ] 🤝 Make re-runs safe: skip filings that are already saved
- [ ] ✍️ Run it on all filings
- [ ] ✍️ Spot-check: find the chunk with Apple's revenue table in Supabase

**Learn:**

- **Token:** a piece of a word (roughly 4 characters). AI models read, count and charge in tokens.
- **Chunk:** a small piece of a filing. The AI can only read so much at once, and small pieces make search precise.
- **Overlap:** neighboring chunks share a few sentences, so an idea cut in half still appears whole in one chunk.
- **Metadata:** the label on each chunk (company, year, page). Without it, we can't cite anything.
- **Embedding:** a list of 1,536 numbers that represents meaning. Similar meaning gives nearby numbers, like coordinates on Google Maps.
- **Batching:** sending many chunks in one API call. It's faster and you hit rate limits less often.
- **Idempotent:** running it twice gives the same result as running it once, with no duplicates.

**Explain it back:**

- Why cut filings into chunks instead of sending the whole filing to the AI?
- What goes wrong without overlap?
- What does an embedding represent? Explain it with the Google Maps example.

---

## Phase 6 — Search ⭐

**Goal:** a question returns the most relevant passages.

- [ ] ✍️ Meaning search with pgvector
- [ ] ✍️ Keyword search with Postgres full-text search
- [ ] ✍️ Merge both result lists with RRF in Python
- [ ] 🤝 Retriever: question in, merged passages (plus their neighbor chunks) out
- [ ] ✍️ Tests for RRF
- [ ] ✍️ Try the 10 questions from the [client brief](client-brief.md) and look at what comes back

**Learn:**

- **Distance:** how far apart two embeddings are. Small distance means similar meaning.
- **HNSW index:** a shortcut that finds the nearest embeddings fast without checking every chunk.
- **Full-text search:** finds exact words. `tsvector` is the searchable version of the text; `tsquery` is the search.
- **Hybrid search:** meaning search plus keyword search. Each one catches what the other misses.
- **RRF (Reciprocal Rank Fusion):** merges two ranked lists. Chunks ranked high on **both** lists win.
- **Top-k:** how many results we keep, for example the best 8.

**Explain it back:**

- Give one question where keyword search wins, and one where meaning search wins.
- In RRF, why does a chunk ranked #3 on both lists beat a chunk ranked #1 on only one list?

---

## Phase 7 — AI answers ⭐

**Goal:** answers that use only the filings, with every citation checked. This is the heart of the product.

- [ ] ✍️ `assistant/instructions.md`: the rules for the AI. You write this prompt yourself.
- [ ] 🤝 PydanticAI agent with typed input and a typed output (`GroundedAnswer`)
- [ ] 🤝 Agent tools: `search_filings`, `read_chunk`, `read_surrounding_chunks`
- [ ] ✍️ Grounding validator: every citation must match a passage we actually retrieved
- [ ] 🤖 Orchestrator: retrieve → agent → validate → stream → save
- [ ] 🤖 Stream real answers plus citation data to the frontend
- [ ] 🤖 Save citations to the database
- [ ] ✍️ Tests for the validator
- [ ] ✍️ Check the behavior: answers cite pages, vague questions get "not enough evidence", and question 10 refuses to guess

**Learn:**

- **System prompt (instructions):** the rules the AI follows on every question.
- **Messages:** an AI conversation is a list of messages with roles: system, user, assistant.
- **Structured output:** the AI replies in a fixed shape (answer plus citations) instead of free text. It's like `fromJson` into a model.
- **Tool calling:** the AI can ask your code to run a function (like "search the filings"). Your code runs it and hands back the result.
- **Agent:** an AI that can call tools several times, in a loop, until it has enough to answer.
- **Hallucination:** the AI confidently making something up. It's the number one enemy here.
- **Grounding:** every claim is backed by a real passage we can show.
- **Fail closed:** when a check fails, return a safe "can't answer" instead of a risky answer.

**Explain it back:**

- What is a "tool" for an AI agent? Give an example that would fit in ZERO.40.
- Why do we check citations in code instead of only trusting the prompt?
- What does "fail closed" mean, and why does this client need it?

---

## Phase 8 — Trust UI

**Goal:** an analyst can check any claim in one tap.

- [ ] 🤖 Citation chips on answers (company, filing, date, page)
- [ ] 🤖 Source passage bottom sheet that shows the exact text for a tapped citation
- [ ] 🤖 Empty states (no chats yet, nothing found)
- [ ] 🤖 Error states (login expired, search failed, grounding failed, network error)
- [ ] 🤖 Loading and streaming status
- [ ] ✍️ Test it: tap a citation and see the exact passage from the filing

**Learn:**

- **Data flow:** how one citation travels from a database row, through the backend, to a chip on screen.
- **Trust UX:** why showing the source matters more than a beautiful answer.

**Explain it back:**

- Trace one citation, step by step, from the database to the screen.

---

## Phase 9 — Evals ⭐ (our addition)

**Goal:** measure answer quality with numbers instead of feelings.

- [ ] ✍️ For each of the 10 brief questions, write what a good answer must include (key facts and which filing)
- [ ] 🤝 A script that runs all 10 questions and saves the answers
- [ ] ✍️ Score each answer: correct? cited? refused when it should? Start by hand.
- [ ] 🤝 Add an LLM judge that scores answers automatically
- [ ] ✍️ Change one thing (like chunk size or top-k), re-run, and compare the scores
- [ ] 🤖 Logging with `structlog`, so failed answers are easy to debug
- [ ] ✍️ Check speed: the answer starts streaming within a few seconds
- [ ] ✍️ Check that chat history survives logging out and back in

**Learn:**

- **Eval:** a repeatable test for AI quality. AI output changes run to run, so you measure instead of guessing.
- **Golden set:** your fixed list of questions with known good answers.
- **LLM-as-judge:** using an AI to grade another AI's answers against your rules.
- **Regression:** a change that makes something worse. Evals catch it before users do.

**Explain it back:**

- Why isn't "I tried a few questions and they looked fine" good enough?
- What did changing chunk size or top-k do to your scores, and why?

---

## Phase 10 — Go live

**Goal:** the backend runs on the internet and the app is installed on real phones.

- [ ] 🤖 Railway: backend service with its environment variables
- [ ] ✍️ Build the app and share it with testers (TestFlight / Firebase App Distribution), like your ZERO.40 tester builds
- [ ] ✍️ Turn email confirmation back on in Supabase, with a link that opens the app
- [ ] 🤝 Run migrations and ingestion against the production database
- [ ] ✍️ Test everything with the installed app against the live backend

**Learn:**

- **Environments:** dev and production, like your `--test` and `--prod` in ZERO.40.
- **Environment variables on a server:** the `.env` values, set in Railway's dashboard instead of a file.
- **Build-time variables:** `env.json` values get baked into the app when it's built, so anyone with the app can read them.
- **Deep link:** a link that opens your app, like the `app_links` setup in ZERO.40. The email confirmation link needs one.

**Explain it back:**

- Why must a value in the Flutter app's `env.json` never be a secret?

---

## Phase 11 — Portfolio

**Goal:** someone can understand your project in 2 minutes.

- [ ] ✍️ README: what it does, an architecture diagram, key decisions and why, eval results, live link, screenshots
- [ ] ✍️ A short demo video or GIF
- [ ] ✍️ A "What I learned" section in your own words
