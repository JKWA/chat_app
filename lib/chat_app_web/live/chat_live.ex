defmodule ChatAppWeb.ChatLive do
  use Phoenix.LiveView
  
  import Ecto.Query, only: [order_by: 2]
  alias Phoenix.PubSub
  alias ChatApp.Chat.Message
  alias ChatApp.Repo

  def mount(_params, _session, socket) do
    PubSub.subscribe(ChatApp.PubSub, "chat")
    PubSub.subscribe(ChatApp.PubSub, "chat_delete")

    messages = fetch_messages()
    {:ok, assign(socket, messages: messages, new_message: "")}
  end

  def handle_event("click_send", _params, socket) do
    send_message(socket, socket.assigns.new_message)
  end

  def handle_event("message_input", %{"message" => message_content}, socket) do
    {:noreply, assign(socket, new_message: message_content)}
  end

  def handle_event("keydown", _, socket), do: {:noreply, socket}

  def handle_event("delete_message", %{"id" => id_string}, socket) do
    handle_delete_message(socket, String.to_integer(id_string))
  end

  def handle_info({id, message_content, timestamp, pid}, socket) when is_integer(id) and is_binary(message_content) and is_pid(pid) do
    messages = [{id, message_content, timestamp, pid} | socket.assigns.messages]
    {:noreply, assign(socket, messages: messages)}
  end

  def handle_info({:delete, id}, socket) when is_integer(id) do
    updated_messages = Enum.filter(socket.assigns.messages, fn {msg_id, _, _, _} -> msg_id != id end)
    {:noreply, assign(socket, messages: updated_messages)}
  end

  def render(assigns) do
  ~H"""
    <div class="min-h-screen  h-96 flex flex-col bg-gray-900 text-gray-200 p-6">
      <h1 class="text-3xl font-bold mb-4">Chat</h1>
      <div class="flex-1 bg-gray-800 p-4 rounded shadow overflow-y-auto mb-4" id="chat-messages" phx-hook="ScrollToBottom">
        <ul class="flex flex-col-reverse" >
        <%= for {id, message_content, timestamp, pid} <- @messages do %>
          <% formatted_timestamp = human_friendly_date(timestamp) %>
          <li class="flex justify-between p-2 border-b border-gray-700">
            <span class="text-gray-300"><%= message_content %></span>
            <div class="flex items-center">
              <span class="text-gray-500 text-sm"><%= inspect(pid) %></span>
              <span class="ml-4 text-gray-600 text-xs"><%= formatted_timestamp %></span>
              <button phx-click="delete_message" phx-value-id={id} class="ml-4 bg-red-500 hover:bg-red-600 text-white px-2 py-1 rounded">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
                </svg>
              </button>
            </div>
          </li>

          <% end %>
        </ul>
      </div>
      <form phx-submit="click_send" class="flex items-center">
        <input type="text" name="message" value={@new_message} placeholder="Type a message..." 
          class="flex-1 p-2 bg-gray-700 rounded mr-2 text-gray-300" 
          phx-keydown="keydown"
          phx-change="message_input"
        />
        <button type="submit" class="bg-indigo-500 hover:bg-indigo-600 text-white px-4 py-2 rounded">Send</button>
      </form>
    </div>
    """
  end

  defp fetch_messages() do
    db_messages = Message
    |> order_by(desc: :timestamp)
    |> Repo.all()

    Enum.map(db_messages, fn msg ->
      {msg.id, msg.content, msg.timestamp, msg.pid}
    end)
  end

  defp send_message(socket, message_content) do
    if String.trim(message_content) != "" do
      timestamp = NaiveDateTime.utc_now()
      pid = inspect(self())

      changeset = 
        %Message{}
        |> Message.changeset(%{content: message_content, timestamp: timestamp, pid: pid})

      {:ok, message} = Repo.insert(changeset)

      broadcasted_message = {message.id, message_content, timestamp, self()}
      PubSub.broadcast(ChatApp.PubSub, "chat", broadcasted_message)
    end

    {:noreply, assign(socket, new_message: "")}
  end

  defp handle_delete_message(socket, id) do
    case Repo.get(Message, id) do
      nil ->
        {:noreply, socket}

      message ->
        Repo.delete!(message)
        PubSub.broadcast(ChatApp.PubSub, "chat_delete", {:delete, id})

        updated_messages = Enum.filter(socket.assigns.messages, fn {msg_id, _, _, _} -> msg_id != id end)
        {:noreply, assign(socket, messages: updated_messages)}
    end
  end

  defp human_friendly_date(datetime) do
    now = DateTime.utc_now()
    datetime_utc = DateTime.from_naive!(datetime, "Etc/UTC")
    seconds_diff = DateTime.diff(now, datetime_utc)

    cond do
      seconds_diff < 60 -> "just now"
      seconds_diff < 3600 -> "#{div(seconds_diff, 60)} minutes ago"
      seconds_diff < 86_400 -> "#{div(seconds_diff, 3600)} hours ago"
      seconds_diff < 172_800 -> "yesterday"
      true -> "#{div(seconds_diff, 86_400)} days ago"
    end
  end

end
