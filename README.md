# ChatApp

Built with Phoenix LiveView and OTP, ChatApp provides a real-time web chatting experience.

## LiveView & OTP

### Processes

- Every LiveView session runs within an independent Erlang/Elixir process, ensuring one session hiccup doesn't affect others.

### Real-time Communication

- User interactions, like button clicks, are sent as messages to the server-side LiveView process.
- LiveView sessions subscribe to chat events using Phoenix's PubSub for real-time synchronization.

### State & Concurrency

- A LiveView session's state, including form data, is retained in memory.
- With OTP, multiple users can interact concurrently with LiveView components.

### Robustness

- Supervisors in OTP monitor LiveView sessions, restarting any crashed session to maintain consistent service.

## PostgreSQL Integration

ChatApp harnesses PostgreSQL's robustness:

- Phoenix and its database library, Ecto, work seamlessly with PostgreSQL, benefiting from features like JSON support and full-text search.
- PostgreSQL's MVCC facilitates multiple simultaneous database interactions, vital for real-time applications.

## ChatAppWeb.ChatLive Highlights

### Key Functions

- **mount/3**: Initializes the chat, subscribing to chat topics and setting up the LiveView socket state.
- **handle_event/3**: Manages user-triggered events like sending or deleting messages.
- **handle_info/2**: Handles server-side messages like new chat messages or chat deletions.
- **render/1**: Provides the chat UI's HTML representation.

## WebSockets in Phoenix LiveView

WebSockets play a pivotal role:

1. **Persistent Connection**: Keeps an ongoing connection, eliminating repeated connection setups.
2. **Low Latency**: Enables near-instantaneous chat messages.
3. **Minimal Overhead**: Reduces data transfer overhead compared to HTTP.
4. **Bidirectional Communication**: Both ends can push data simultaneously, enhancing responsiveness.
5. **Efficiency**: Bypasses the inefficiencies of polling, saving on traffic and server load.

## Diffs in LiveView

LiveView computes and transmits minimal diffs:

- The server retains the initial state.
- On an event, the server re-renders and computes differences between the old and new state.
- Only these differences (diffs) are sent to the client, ensuring quick updates and bandwidth conservation.

## Reliability in ChatApp

Phoenix LiveView guarantees a seamless chat experience:

- Maintains a consistent server-side state.
- Uses WebSockets for uninterrupted communication.
- Regularly monitors and re-establishes connection, if needed.
- Leverages Erlang/OTP's fault tolerance; if a session crashes, it restarts.
- Phoenix PubSub ensures all chat messages reach subscribers, even if missed initially.

## Installation & Setup

1. **Install Elixir**:

   ```bash
   brew install elixir
   ```

2. **Phoenix**:

   ```bash
   mix archive.install hex phx_new 1.5.7
   ```

   More details in the [Phoenix installation guide](https://hexdocs.pm/phoenix/installation.html).

3. **PostgreSQL**:

   ```bash
   brew install postgresql
   brew services start postgresql
   ```

4. **Setup PostgreSQL User**:

   ```bash
   psql postgres
   ```

   ```sql
   CREATE USER postgres WITH PASSWORD 'postgres' CREATEDB;
   ```

5. **Fetch dependencies**:

   ```bash
   mix deps.get
   ```

6. **Database setup**:

   ```bash
   mix ecto.setup
   ```

7. **Start server**:

   ```bash
   mix phx.server
   ```

Open [`localhost:4000`](http://localhost:4000) in multiple tabs to make concurrent chats.
