# Creates a relay, gateway and client token for the provisioned test account
# and writes them to the working directory, from where the test copies them
# to the other nodes.
alias Portal.{Account, Actor, Authentication, Repo, Site}
alias Portal.Authentication.{Context, Credential, Subject}

mappings = "provision-uuids.json" |> File.read!() |> JSON.decode!()

IO.puts("INFO: Fetching provisioned account, site and service account")
account = Repo.get_by!(Account, slug: "main")
site = Repo.get_by!(Site, account_id: account.id, id: get_in(mappings, ["accounts", "main", "gateway_groups", "site"]))
actor = Repo.get_by!(Actor, account_id: account.id, id: get_in(mappings, ["accounts", "main", "actors", "client"]))

# Token creation is scoped to an admin subject, which we synthesize here
# instead of signing in.
subject = %Subject{
  account: account,
  actor: %Actor{
    id: Ecto.UUID.generate(),
    account_id: account.id,
    type: :account_admin_user,
    name: "NixOS test"
  },
  credential: %Credential.PortalSession{
    id: Ecto.UUID.generate(),
    auth_provider_id: Ecto.UUID.generate()
  },
  expires_at: DateTime.add(DateTime.utc_now(), 1, :hour),
  context: %Context{
    type: :portal,
    remote_ip: {127, 0, 0, 1},
    user_agent: "nixos-test/1.0"
  }
}

IO.puts("INFO: Creating relay token")
{:ok, relay_token} = Authentication.create_relay_token()
File.write!("relay_token.txt", Authentication.encode_fragment!(relay_token))

IO.puts("INFO: Creating gateway token")
{:ok, gateway_token} = Authentication.create_gateway_token(site, subject)
File.write!("gateway_token.txt", Authentication.encode_fragment!(gateway_token))

IO.puts("INFO: Creating client token")

{:ok, client_token} =
  Authentication.create_non_interactive_client_token(
    actor,
    %{expires_at: DateTime.add(DateTime.utc_now(), 1, :hour)},
    subject
  )

File.write!("client_token.txt", Authentication.encode_fragment!(client_token))
IO.puts("INFO: Tokens created")
