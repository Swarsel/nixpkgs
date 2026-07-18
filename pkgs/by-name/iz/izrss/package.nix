{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "izrss";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "isabelroses";
    repo = "izrss";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8eHUskfsdymVTYt5V/f75vKsvmuZz/CNGqbthSQrHow=";
  };

  vendorHash = "sha256-NP363PtrTcI1EubIBJEoMCTkHCGsNRM8fY2fgwSlz5s=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "RSS feed reader for the terminal written in Go";
    homepage = "https://github.com/isabelroses/izrss";
    changelog = "https://github.com/isabelroses/izrss/releases/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      isabelroses
      luftmensch-luftmensch
    ];

    mainProgram = "izrss";
  };
})
