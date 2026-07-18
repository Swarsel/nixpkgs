{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "nix-build-uncached";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-build-uncached";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-n9Koi01Te77bpYbRX46UThyD2FhCu9OGHd/6xDQLqjQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = null;
  doCheck = false;

  meta = {
    description = "CI friendly wrapper around nix-build";
    homepage = "https://github.com/Mic92/nix-build-uncached";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mic92 ];
    mainProgram = "nix-build-uncached";
  };
})
