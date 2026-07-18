{
  lib,
  buildGo125Module,
  winboat,
}:

buildGo125Module {
  inherit (winboat) version src;
  pname = "winboat-guest-server";
  vendorHash = "sha256-vpBvSaqbbJ8sHNMm299z/3Qb7FKMWbr62amtKT3acYk=";

  env = {
    GOARCH = "amd64";
    GOOS = "windows";
    PACKAGE = "winboat-server";
  };

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${winboat.version}"
    "-X main.CommitHash=${winboat.src.rev}"
  ];

  modRoot = "guest_server";

  meta = {
    description = "Guest server for winboat";
    homepage = "https://github.com/TibixDev/winboat";
    changelog = "https://github.com/TibixDev/winboat/releases/tag/v${winboat.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      rexies
      ppom
    ];

    platforms = [ "x86_64-windows" ];
    mainProgram = "winboat-server.exe";
  };
}
