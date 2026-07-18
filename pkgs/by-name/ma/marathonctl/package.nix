{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "marathonctl";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "shoenig";
    repo = "marathonctl";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-MigmvOwYa0uYPexchS4MP74I1Tp6QHYuQVSOh1+FrMg=";
  };

  vendorHash = "sha256-Oiol4KuPOyJq2Bfc5div+enX4kQqYn20itmwWBecuIg=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "CLI tool for Marathon";
    homepage = "https://github.com/shoenig/marathonctl";
    license = lib.licenses.mit;
    mainProgram = "marathonctl";
  };
})
