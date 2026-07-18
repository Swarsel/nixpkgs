{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "go-ecoflow-exporter";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "tess1o";
    repo = "go-ecoflow-exporter";
    tag = finalAttrs.version;
    hash = "sha256-y273U4314oydC94sdFKiAEoZ7n4bYgiUxXf71p82qAc=";
  };

  vendorHash = "sha256-hsyEv+K8qL9KOrh5L6meeBOvE/WQ4F6hGBY5bWN0EFE=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ecoflow solar battery mqtt timescale, redis, prometheus metrics exporter";
    homepage = "https://github.com/tess1o/go-ecoflow-exporter";
    changelog = "https://github.com/tess1o/go-ecoflow-exporter/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "go-ecoflow-exporter";
  };
})
