{
  lib,
  fetchFromGitHub,
  libgit2,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pullomatic";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "fooker";
    repo = "pullomatic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qPuJ2mqbqQQxncsz5DexOYyNctIInX0Of5mdAGu/t/M=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    libgit2
  ];

  cargoHash = "sha256-+B/DzDaF3qQlPzjh97CBMAseyeUClgsgzE0EJ8kTlqg=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Automates Git repository syncing through pure configuration";
    homepage = "https://github.com/fooker/pullomatic";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fooker ];
    mainProgram = "pullomatic";
  };
})
