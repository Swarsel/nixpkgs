{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rover";
  version = "0.37.2";

  src = fetchFromGitHub {
    owner = "apollographql";
    repo = "rover";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0lzMrec9rJENKTMofDKAXH7b7kK2ElHplNtlf9/nqkQ=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-nMb0kwtzYmfOB+Ub8vXK39wp3vAe5HNFb9k579We26c=";

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  # Some tests try to write configuration data to a location in the user's home
  # directory. Since this would be /homeless-shelter during the build, point at
  # a writeable location instead.
  preCheck = ''
    export APOLLO_CONFIG_HOME="$PWD"
  '';

  __darwinAllowLocalNetworking = true;

  # This test checks whether the plugins specified in the plugins json file are
  # valid by making a network call to the repo that houses their binaries; but, the
  # build env can't make network calls (impurity)
  cargoTestFlags = [
    "--"
    "--skip=latest_plugins_are_valid_versions"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for interacting with ApolloGraphQL's developer tooling, including managing self-hosted and GraphOS graphs";
    homepage = "https://www.apollographql.com/docs/rover";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.ivanbrennan
      lib.maintainers.aaronarinder
    ];

    mainProgram = "rover";
  };
})
