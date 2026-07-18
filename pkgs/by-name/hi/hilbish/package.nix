{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "hilbish";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "sammy-ette";
    repo = "Hilbish";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rEBUrDdJBCywuSmsxFLl4+uSwz06km2nztH5aCGcGiE=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-8t3JBQEAmWcAlgA729IRpiewlgnRd5DQxHLTfwquE3o=";

  postInstall = ''
    mkdir -p "$out/share/hilbish"

    cp .hilbishrc.lua $out/share/hilbish/
    cp -r docs -t $out/share/hilbish/
    cp -r libs -t $out/share/hilbish/
    cp -r nature $out/share/hilbish/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.dataDir=${placeholder "out"}/share/hilbish"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Interactive Unix-like shell written in Go";
    homepage = "https://github.com/sammy-ette/Hilbish";
    changelog = "https://github.com/sammy-ette/Hilbish/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moni ];
    mainProgram = "hilbish";
  };
})
