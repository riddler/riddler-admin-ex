defmodule RiddlerAdmin.AgentsTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Agents

  describe "agents" do
    alias RiddlerAdmin.Agents.Agent

    @valid_attrs %{api_key: "some api_key", api_secret: "some api_secret", name: "some name"}
    @update_attrs %{api_key: "some updated api_key", api_secret: "some updated api_secret", name: "some updated name"}
    @invalid_attrs %{api_key: nil, api_secret: nil, name: nil}

    def agent_fixture(attrs \\ %{}) do
      {:ok, agent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Agents.create_agent()

      agent
    end

    test "list_agents/0 returns all agents" do
      agent = agent_fixture()
      assert Agents.list_agents() == [agent]
    end

    test "get_agent!/1 returns the agent with given id" do
      agent = agent_fixture()
      assert Agents.get_agent!(agent.id) == agent
    end

    test "create_agent/1 with valid data creates a agent" do
      assert {:ok, %Agent{} = agent} = Agents.create_agent(@valid_attrs)
      assert agent.api_key == "some api_key"
      assert agent.api_secret == "some api_secret"
      assert agent.name == "some name"
    end

    test "create_agent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Agents.create_agent(@invalid_attrs)
    end

    test "update_agent/2 with valid data updates the agent" do
      agent = agent_fixture()
      assert {:ok, %Agent{} = agent} = Agents.update_agent(agent, @update_attrs)
      assert agent.api_key == "some updated api_key"
      assert agent.api_secret == "some updated api_secret"
      assert agent.name == "some updated name"
    end

    test "update_agent/2 with invalid data returns error changeset" do
      agent = agent_fixture()
      assert {:error, %Ecto.Changeset{}} = Agents.update_agent(agent, @invalid_attrs)
      assert agent == Agents.get_agent!(agent.id)
    end

    test "delete_agent/1 deletes the agent" do
      agent = agent_fixture()
      assert {:ok, %Agent{}} = Agents.delete_agent(agent)
      assert_raise Ecto.NoResultsError, fn -> Agents.get_agent!(agent.id) end
    end

    test "change_agent/1 returns a agent changeset" do
      agent = agent_fixture()
      assert %Ecto.Changeset{} = Agents.change_agent(agent)
    end
  end
end
