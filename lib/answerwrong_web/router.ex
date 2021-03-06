defmodule AnswerwrongWeb.Router do
  use AnswerwrongWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AnswerwrongWeb do
    pipe_through :browser # Use the default browser stack

    resources "/users", UserController
    resources "/questions", QuestionController
    resources "/answers", AnswerController
    get "/leaderboard", AnswerController, :leaderboard
    get "/myanswers", AnswerController, :my_answers

    get "/", PageController, :index
    get "/quiz", QuizController, :quiz
    get "/winner", QuizController, :winner
    post "/answer", QuizController, :quiz_answer
    get "/play_again", QuizController, :play_again

    get "/multiplayer", MultiPlayerController, :room
  end

  # Other scopes may use custom stacks.
  # scope "/api", AnswerwrongWeb do
  #   pipe_through :api
  # end
end
