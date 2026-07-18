{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "chroma";
  version = "2.27.0";

  src = fetchFromGitHub {
    owner = "alecthomas";
    repo = "chroma";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iIu0FFAavXbma/LiKEDltvrGMYYd4uxSfHpNTrmN6aI=";
  };

  vendorHash = "sha256-B2TvCIBqgdTpQApmQkO2COIarqmgF9mhZ0HG5aFgVhY=";

  # substitute version info as done in goreleaser builds
  ldflags = [
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=${finalAttrs.src.tag}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  modRoot = "./cmd/chroma";

  meta = {
    description = "General purpose syntax highlighter in pure Go";
    homepage = "https://github.com/alecthomas/chroma";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ miniharinn ];
    mainProgram = "chroma";
  };
})
