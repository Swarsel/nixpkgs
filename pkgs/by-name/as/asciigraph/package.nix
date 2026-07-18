{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "asciigraph";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "guptarohit";
    repo = "asciigraph";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+4aGkumO42cloHWV8qEEJ5bj8TTdtfXTWGFCgCRE4Mg=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Lightweight ASCII line graph ╭┈╯ command line app";
    homepage = "https://github.com/guptarohit/asciigraph";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mmahut ];
    mainProgram = "asciigraph";
  };
})
