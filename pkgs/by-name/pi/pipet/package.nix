{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "pipet";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "bjesus";
    repo = "pipet";
    rev = finalAttrs.version;
    hash = "sha256-pu+2sHdLz9TvYHBwvGTtFr/oAD+CreOR8io82YQANxc=";
  };

  vendorHash = "sha256-jNIjF5jxcpNLAjuWo7OG/Ac4l6NpQNCKzYUgdAoL+C4=";
  doCheck = false; # Requires network

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.currentSha=${finalAttrs.src.rev}"
  ];

  meta = {
    description = "Scraping and extracting data from online assets";
    homepage = "https://github.com/bjesus/pipet";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bjesus ];
    mainProgram = "pipet";
  };
})
