defmodule Discordbot.Filters.QuestionsTest do

  use ExUnit.Case, async: true

  alias Discordbot.Filters.Questions

  @questions [
    "Quelqu'un de calé en JS ?",
    "Quelqu'un utilise ou à déjà utilisé Bramus ici ?",
    "Des personnes qui utilisent Kubernetes ?",
    "Des personnes assez costaud en contrainte de SGBD Ici ?",
    "Des personnes adeptes de rails ?",
    "Des personnes dév sous rails ici ? ",
    "des gens fort en es 2015 ?",
    "quelqu'un à déjà eu à réaliser une map de rpg?",
    "Des gens fort en PHP ?",
    "Des gens pour m'aider sur rails",
    "Des personnes pour m'aider sur php ?",
    "Des personnes fortes en php ?",
    "Des gens pour m'aider en js ?",
    "Des personnes fortes en js ?",
    "Bonjour qui s'y connaît bien en Rails please ?",
    "Des gens pour de l'aide sur elixir ?",
    "Qqn peut m'aider ?",
    "Des gens pour m'aider ?",
    "Une personne pour m'aider ?",
    "Des dev php dispo ?"
  ]
  @not_questions [
    "eu, dis toujours",
    "Quelqu'un qui est callé en php pourrait me dire comment détecter la session utilisateur en PHP ?",
    "si je fais ça ça veut dire que je ne publie aucune autre vidéo pendant 2/3 semaines",
    "Pourquoi s'emebeter avec plein de methodes pour les getters et setters ?"
  ]

  setup do
    {:ok, state: %{rest_client: self()}}
  end

  test "should detect questions" do
    assert [] == @questions |> Enum.filter(&!Questions.is_question?(&1))
  end

  test "should let normal sentences pass" do
    assert [] == @not_questions |> Enum.filter(&Questions.is_question?(&1))
  end

  test "should help the user", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => List.first(@questions)
    })
    url = "channels/" <> Integer.to_string(message["channel_id"]) <> "/messages"
    {:ok, _} = Questions.handle(:message_create, message, state)
    assert_receive {_, _, {_, :post, ^url, _}}
  end

  test "should do nothing for other uses", %{state: state} do
    message = DiscordbotTest.message(%{
      "content" => List.first(@not_questions)
    })
    {:no, _} = Questions.handle(:message_create, message, state)
  end

end
