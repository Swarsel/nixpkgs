{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

let
  version = "1.0.0";
in
buildGoModule {
  inherit version;
  pname = "vault-unseal";

  src = fetchFromGitHub {
    owner = "lrstanley";
    repo = "vault-unseal";
    rev = "v${version}";
    hash = "sha256-czfG7DsA6O2n8BlzEEvNtu0Dg277qBnLAdVUZLo6+8w=";
  };

  vendorHash = "sha256-ma3xbnWH87b1X5fdOjigzsj5gEfhbjyTLoIDyp9eY80=";

  meta = {
    description = "Auto-unseal utility for Hashicorp Vault";
    homepage = "https://github.com/lrstanley/vault-unseal";
    changelog = "https://github.com/lrstanley/vault-unseal/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mjm ];
    mainProgram = "vault-unseal";
  };
}
