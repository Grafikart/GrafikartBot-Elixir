defmodule Discordbot.Filters.CodeTest do

  use ExUnit.Case, async: true

  doctest Discordbot.Filters.Code
  alias Discordbot.Filters.Code

  @code """
      if(isset($_SESSION['id']) AND !empty($_SESSION['id']))
      {
          $id_planete_utilise=$_SESSION['planete_utilise'];
          $req_affichage_defense=$bdd->prepare('SELECT * FROM defense WHERE id_planete = ?');
          $req_affichage_defense->execute(array($id_planete_utilise));
          while($affichage_defense=$req_affichage_defense->fetch());
          $req_affichage_defense=$bdd->prepare('SELECT * FROM defense WHERE id_planete = ?');
          $req_affichage_defense->execute(array($id_planete_utilise));
          while($affichage_defense=$req_affichage_defense->fetch());
      }
    """

  setup do
    {:ok, state: %{rest_client: self()}}
  end

  test "should detect PHP Code" do
    assert Code.is_code(@code) == true
  end

  test "should allow small piece of code" do
    code = """
    if(isset($_SESSION['id']) AND !empty($_SESSION['id'])){
        $id_planete_utilise=$_SESSION['planete_utilise'];
    }
    """
    assert Code.is_code(code) == false
  end

  test "should detect bash code" do
    code = """
    #!/bin/bash
   
    $server=$1
    $map=$2
    if [ map == 'tower' ]; then
      cd /servers/server;
   
    $server=$1
    $map=$2
    """
    assert Code.is_code(code) == true
  end

  test "should emit a private message", %{state: state} do
    message = Map.merge(DiscordbotTest.message, %{
      "content" => @code
    })
    Code.handle(:message_create, message, state)
    assert_receive {_, _, {_, :delete, _, _}}
  end

  test "should let the admin post code", %{state: state} do
    message = Map.merge(DiscordbotTest.message, %{
      "content" => @code,
      "author"  => %{
        "id" => Application.get_env(:discordbot, :admin)
      }
    })
    assert {:no, _} = Code.handle(:message_create, message, state)
  end

end