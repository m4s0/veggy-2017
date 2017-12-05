defmodule Veggy.Projection.LatestPomodori do
  use Veggy.MongoDB.Projection,
      collection: "projection.latest_pomodori",
      events: ["LoggedIn", "PomodoroStarted", "PomodoroCompleted", "PomodoroSquashed"],
      identity: "timer_id"

  def process(%{"event" => "LoggedIn"} = e, r) do
    r
    |> Map.put("user_id", e["user_id"])
    |> Map.put("timer_id", e["timer_id"])
    |> Map.put("username", e["username"])
  end

  def process(%{"event" => "PomodoroStarted"} = e, r) do
    r
    |> Map.put("started_at", e["_received_at"])
    |> Map.put("duration", e["duration"])
    |> Map.put("status", e["started"])
    |> Map.delete("completed_at")
    |> Map.delete("squashed_at")
  end

  def process(%{"event" => "PomodoroStarted"} = e, r) do
    r
    |> Map.put("completed_at", e["_received_at"])
    |> Map.put("status", e["completed"])
  end

  def process(%{"event" => "PomodoroSquashed"} = e, r) do
    r
    |> Map.put("squashed_at", e["_received_at"])
    |> Map.put("status", e["squashed"])
  end

  def query("latest-pomodoro", %{"timer_id" => timer_id}) do
    find_one(
      %{
        "timer_id" => Veggy.MongoDB.ObjectId.from_string(timer_id),
        "started_at" => %{
          "exists" => true
        }
      }
    )
  end

  def query("latest-pomodori", _) do
    find(%{})
  end

end

