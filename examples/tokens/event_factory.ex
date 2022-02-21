defmodule Examples.Tokens.EventFactory do
  @type opt :: {:approval_enabled, boolean} | {:transfer_enabled, boolean}

  @spec create([opt]) :: [Slurp.EventFactory.log_subscription_config_tuple]
  def create(opts) do
    [
      approval(enabled: Slurp.EventFactory.get_opt(opts, :approval_enabled, true)),
      approval_for_all(enabled: Slurp.EventFactory.get_opt(opts, :approval_enabled, true)),
      transfer(enabled: Slurp.EventFactory.get_opt(opts, :transfer_enabled, true))
    ]
  end

  @approval_event_signature "Approval(address,address,uint256)"
  defp approval(enabled: enabled) do
    event_mappings = [
      erc20_approval_event(),
      erc721_approval_event(),
    ]
    handler_configs = [
      Slurp.EventFactory.handler_config(
        enabled: enabled,
        event_mappings: event_mappings,
        handler: {Examples.EventHandler, :handle_token_approval, []}
      )
    ]

    {@approval_event_signature, handler_configs}
  end

  defp erc20_approval_event do
    abi = %{
      "anonymous" => false,
      "inputs" => [
        %{
          "indexed" => true,
          "name" => "owner",
          "type" => "address"
        },
        %{
          "indexed" => true,
          "name" => "spender",
          "type" => "address"
        },
        %{
          "indexed" => false,
          "name" => "value",
          "type" => "uint256"
        }
      ],
      "name" => "Approval",
      "type" => "event"
    }

    {Examples.Tokens.Events.Erc20.Approval, abi}
  end

  defp erc721_approval_event do
    abi = %{
      "anonymous" => false,
      "inputs" => [
        %{
          "indexed" => true,
          "name" => "owner",
          "type" => "address"
        },
        %{
          "indexed" => true,
          "name" => "approved",
          "type" => "address"
        },
        %{
          "indexed" => true,
          "name" => "tokenId",
          "type" => "uint256"
        }
      ],
      "name" => "Approval",
      "type" => "event"
    }

    {Examples.Tokens.Events.Erc721.Approval, abi}
  end

  @approval_for_all_event_signature "ApprovalForAll(address,address,bool)"
  defp approval_for_all(enabled: enabled) do
    event_mappings = [
      erc721_approval_for_all_event(),
    ]
    handler_configs = [
      Slurp.EventFactory.handler_config(
        enabled: enabled,
        event_mappings: event_mappings,
        handler: {Examples.EventHandler, :handle_token_approval_for_all, []}
      )
    ]

    {@approval_for_all_event_signature, handler_configs}
  end

  defp erc721_approval_for_all_event do
    abi = %{
      "anonymous" => false,
      "inputs" => [
        %{
          "indexed" => true,
          "name" => "owner",
          "type" => "address"
        },
        %{
          "indexed" => true,
          "name" => "operator",
          "type" => "address"
        },
        %{
          "indexed" => false,
          "name" => "approved",
          "type" => "bool"
        }
      ],
      "name" => "ApprovalForAll",
      "type" => "event"
    }

    {Examples.Tokens.Events.Erc721.ApprovalForAll, abi}
  end

  @transfer_event_signature "Transfer(address,address,uint256)"
  defp transfer(enabled: enabled) do
    event_mappings = [
      erc20_transfer_event(),
      erc721_transfer_event()
    ]
    handler_configs = [
      Slurp.EventFactory.handler_config(
        enabled: enabled,
        event_mappings: event_mappings,
        handler: {Examples.EventHandler, :handle_token_transfer, []}
      )
    ]

    {@transfer_event_signature, handler_configs}
  end

  defp erc20_transfer_event do
    abi = %{
      "anonymous" => false,
      "inputs" => [
        %{
          "indexed" => true,
          "name" => "from",
          "type" => "address"
        },
        %{
          "indexed" => true,
          "name" => "to",
          "type" => "address"
        },
        %{
          "indexed" => false,
          "name" => "value",
          "type" => "uint256"
        }
      ],
      "name" => "Transfer",
      "type" => "event"
    }

    {Examples.Tokens.Events.Erc20.Transfer, abi}
  end

  defp erc721_transfer_event do
    abi = %{
      "anonymous" => false,
      "inputs" => [
        %{
          "indexed" => true,
          "name" => "from",
          "type" => "address"
        },
        %{
          "indexed" => true,
          "name" => "to",
          "type" => "address"
        },
        %{
          "indexed" => true,
          "name" => "tokenId",
          "type" => "uint256"
        }
      ],
      "name" => "Transfer",
      "type" => "event"
    }

    {Examples.Tokens.Events.Erc721.Transfer, abi}
  end
end
