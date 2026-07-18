{
  lib,
  fetchFromGitHub,
  biscuit-cli,
  nix-update-script,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "biscuit-cli";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "eclipse-biscuit";
    repo = "biscuit-cli";
    tag = finalAttrs.version;
    sha256 = "sha256-s4Y4MhM79Z+4VxB03+56OqRQJaSHj2VQEJcL6CsT+2k=";
  };

  cargoHash = "sha256-OG8/9CxOTCYXwyavdaXvak8GbCOMvelcsSJVkEgdMdI=";

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "biscuit --version";
      package = biscuit-cli;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI to generate and inspect biscuit tokens";
    homepage = "https://www.biscuitsec.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ shlevy ];
    mainProgram = "biscuit";
  };
})
