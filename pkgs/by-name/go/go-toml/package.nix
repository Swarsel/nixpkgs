{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  version = "2.3.1";
in
buildGoModule {
  inherit version;
  pname = "go-toml";

  src = fetchFromGitHub {
    owner = "pelletier";
    repo = "go-toml";
    rev = "v${version}";
    sha256 = "sha256-12PFm89E8GI2toBpEZWp+VaAlywI6yBoPjz421GhMu4=";
  };

  vendorHash = null;

  excludedPackages = [
    "cmd/gotoml-test-decoder"
    "cmd/gotoml-test-encoder"
    "cmd/tomltestgen"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = {
    description = "Go library for the TOML language";
    homepage = "https://github.com/pelletier/go-toml";
    changelog = "https://github.com/pelletier/go-toml/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.isabelroses ];
  };
}
