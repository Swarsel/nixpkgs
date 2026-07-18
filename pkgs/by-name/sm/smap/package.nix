{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitUpdater,
}:

buildGoModule (finalAttrs: {
  pname = "smap";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "s0md3v";
    repo = "Smap";
    tag = finalAttrs.version;
    hash = "sha256-GLw0zgjWnEwtwRV4vTHqGUS6TqcFhhZ1zeThKe6S0CY=";
  };

  vendorHash = "sha256-19plbD+ibjoqAA6gGhCvpO52z/VejJkRRh8ljBHN+qY=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/smap" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Drop-in replacement for Nmap powered by shodan.io";
    homepage = "https://github.com/s0md3v/Smap";
    changelog = "https://github.com/s0md3v/Smap/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ yechielw ];
    mainProgram = "smap";
  };
})
