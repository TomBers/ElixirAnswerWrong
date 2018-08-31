defmodule AnswerwrongWeb.RoomChannel do
    use AnswerwrongWeb, :channel

    alias Answerwrong.Content

    alias Answerwrong.Repo

    alias AnswerwrongWeb.Monitor

    def join(name, _auth, socket) do
      send(self, :after_join)
      {int_id, _} = Integer.parse(socket.assigns[:current_user_id])
      user = Answerwrong.Account.get_user(socket.assigns[:current_user_id])
      {:ok, %{current_user_id: socket.assigns[:current_user_id], current_user_name: user.name} , socket}
    end

    def terminate(msg, socket) do
      user_id = socket.assigns.current_user_id
      Monitor.user_left(user_id)
      broadcast!(socket, "message:state_updated", Monitor.get_state())
      {:ok, socket}
    end

    def handle_info(:after_join, socket) do
      push socket, "presence_state", AnswerwrongWeb.Presence.list(socket)

      user = Answerwrong.Account.get_user(socket.assigns[:current_user_id])
      Monitor.set_initial_state("#{user.id}")

      {:ok, _} = AnswerwrongWeb.Presence.track(socket, "user:#{user.id}", %{
        user_id: user.id,
        username: user.name
      })
      {:noreply, socket}
    end

    def handle_in("message:start", params, socket) do
      question = Content.get_random_question
      Monitor.add_question(question)
      broadcast!(socket, "message:state_updated", Monitor.get_state())
      {:reply, :ok, socket}
    end

    def handle_in("message:answer", %{"current_user_id" => id, "answer" => answer}, socket) do
      Monitor.update_answer(id, answer)
      broadcast!(socket, "message:state_updated", Monitor.get_state())
      {:reply, :ok, socket}
    end

    def handle_in("message:guess", %{"current_user_id" => id, "guess" => guess}, socket) do
      Monitor.my_guess(id, guess)
      broadcast!(socket, "message:state_updated", Monitor.get_state())
      {:reply, :ok, socket}
    end

  end
