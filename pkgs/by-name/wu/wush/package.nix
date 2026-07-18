{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  version = "0.4.1";
in
buildGoModule {
  inherit version;
  pname = "wush";

  src = fetchFromGitHub {
    owner = "coder";
    repo = "wush";
    rev = "v${version}";
    hash = "sha256-K83peIfr1+OHuuq6gdgco0RhfF1tAAewb4pxNT6vV+w=";
  };

  vendorHash = "sha256-3/DDtqVj7NNoJlNmKC+Q+XGS182E9OYkKMZ/2viANNQ=";
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X main.version=${version}"
  ];

  meta = {
    description = "Transfer files between computers via WireGuard";
    homepage = "https://github.com/coder/wush";
    changelog = "https://github.com/coder/wush/releases/tag/v${version}";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ abbe ];
    mainProgram = "wush";
  };
}
