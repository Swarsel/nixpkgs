{
  lib,
  fetchFromGitHub,
  beamPackages,
  nix-update-script,
}:
let
  inherit (beamPackages) mixRelease fetchMixDeps;
in
mixRelease rec {
  pname = "protoc-gen-elixir";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "elixir-protobuf";
    repo = "protobuf";
    tag = "v${version}";
    hash = "sha256-hxtG7w+cL02yM2pZ4aL8/nse8qFULP8IhkpX6cCXwwA=";
  };

  escriptBinName = "protoc-gen-elixir";

  mixFodDeps = fetchMixDeps {
    inherit version src;
    pname = "protoc-gen-elixir-deps";
    hash = "sha256-T1uL3xXXmCkobJJhS3p6xMrJUyiim3AMwaG87/Ix7A8=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Protoc plugin to generate Elixir code";
    homepage = "https://github.com/elixir-protobuf/protobuf";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mattpolzin ];
    mainProgram = "protoc-gen-elixir";
  };
}
