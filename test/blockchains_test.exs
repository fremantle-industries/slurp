defmodule Slurp.Specs.Blockchain.Test do
  use ExUnit.Case

  test ".from_config parses Blockchain structs from the application environment" do
    assert {:ok, blockchains} = Slurp.Subscriptions.Blockchains.from_config()

    assert Enum.count(blockchains) == 2
    assert Enum.at(blockchains, 0).id == "ethereum-mainnet"
    assert Enum.at(blockchains, 1).id == "ethereum-ropsten"
  end

  test ".from_config returns an error when the blockchain config is not a map" do
    assert Slurp.Subscriptions.Blockchains.from_config([]) ==
             {:error, "invalid env :blockchains for application :slurp. [] is not a map"}
  end
end
