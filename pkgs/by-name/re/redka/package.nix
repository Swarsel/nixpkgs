{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "redka";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "nalgeon";
    repo = "redka";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ALmRlikIFClzd/bghD3IUolnl3haFhKN+maqaP06dFY=";
  };

  vendorHash = "sha256-76mkNwmqOQCMLoWQr1ExZ2hS5YqiCj7gHQLvMl/wXbY=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/redka"
  ];

  meta = {
    description = "Redis re-implemented with SQLite";
    homepage = "https://github.com/nalgeon/redka";
    changelog = "https://github.com/nalgeon/redka/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sikmir ];
  };
})
