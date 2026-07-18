{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "distrobox-tui";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "phanirithvij";
    repo = "distrobox-tui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uOeJ9f2yXszGUYTxMLwvXCRkmT9Uo7mkZVhpf5HVhbg=";
  };

  vendorHash = "sha256-y64KqlJsZ8aVK7oBcduEC8VvbutoRC15LMUeZdokPfY=";
  ldflags = [ "-s" ];

  meta = {
    description = "TUI for DistroBox";
    homepage = "https://github.com/phanirithvij/distrobox-tui";
    changelog = "https://github.com/phanirithvij/distrobox-tui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = with lib.maintainers; [ phanirithvij ];
    platforms = lib.platforms.linux;
    mainProgram = "distrobox-tui";
  };
})
