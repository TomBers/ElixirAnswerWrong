defmodule AnswerwrongWeb.Monitor do

  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def add_question(question) do
    Agent.update(__MODULE__, fn(state) -> Map.put(state, "current_question", question) end)
    put_users_into_state(1)
  end

  def current_question do
    Agent.get(__MODULE__, fn(state) -> state["current_question"] end)
  end

  def get_state do
    Agent.get(__MODULE__, fn(state) -> state end)
  end

  def get_my_score(user_id) do
    Agent.get(__MODULE__, fn(state) -> state[user_id].score end)
  end

  def set_initial_state(user_id) do
    Agent.update(__MODULE__, fn(state) -> Map.put(state, user_id, %{id: user_id, state: 0, score: 0, answer: nil}) end)
  end

  def update_answer(user_id, answer) do
    add_answer_to_state(user_id, answer)
    case are_all_answers_in() do
      true -> put_users_into_answer_state()
      false -> IO.puts("Waiting")
    end
  end

  def my_guess(user_id, guess) do
    case is_correct_guess(guess) do
      true -> add_to_score(user_id)
      false -> add_to_score(guess)
    end
    update_state(user_id, 0)
  end

  def add_to_score(user_id) do
    Agent.update(__MODULE__, fn(state) -> Map.put(state, user_id, %{id: user_id, answer: state[user_id].answer, score: state[user_id].score + 1, state: state[user_id].state}) end)
  end

  def is_correct_guess(guess) do
    guess === "#{current_question().id}"
  end

  def put_users_into_answer_state do
    put_users_into_state(3)
  end

  def put_users_into_state(state) do
    get_state()
    |> Map.delete("current_question")
    |> Enum.map(fn({user_id, _}) -> update_state(user_id, state) end)
  end

  def are_all_answers_in do
    get_state()
    |> Map.delete("current_question")
    |> Map.values
    |> Enum.all?(fn(x) -> x.state === 2 end)
  end

  def update_state(user_id, game_state) do
    Agent.update(__MODULE__, fn(state) -> Map.put(state, user_id, %{id: user_id, answer: state[user_id].answer, score: state[user_id].score, state: game_state}) end)
  end

  def add_answer_to_state(user_id, answer) do
    Agent.update(__MODULE__, fn(state) -> Map.put(state, user_id, %{id: user_id, answer: answer, state: 2, score: state[user_id].score}) end)
  end

end