{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "smimesign";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "github";
    repo = "smimesign";
    rev = "v${version}";
    hash = "sha256-W9Hj/+snx+X6l95Gt9d8DiLnBPV9npKydc/zMN9G0vQ=";
  };

  vendorHash = "sha256-wLqYUICL+gdvRCLNrA0ZNcFI4oV3Oik762q7xF115Lw=";
  # Fails in sandbox
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.versionString=v${version}"
  ];

  meta = {
    description = "S/MIME signing utility for macOS and Windows that is compatible with Git";
    homepage = "https://github.com/github/smimesign";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.enorris ];
    platforms = lib.platforms.darwin ++ lib.platforms.windows;
  };
}
