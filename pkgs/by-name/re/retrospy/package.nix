{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  makeDesktopItem,
  runCommandLocal,
}:
let
  version = "6.10";

  src = fetchFromGitHub {
    owner = "retrospy";
    repo = "RetroSpy";
    rev = "v${version}";
    hash = "sha256-XupMQRBhX0w6Qv7t0BPhkrjDTOm5HdpLCLSq0gbC3Mk=";
  };

  executables = [
    "RetroSpy"
    "GBPemu"
    "GBPUpdater"
    "UsbUpdater"
  ];

  retrospy-icons = runCommandLocal "retrospy-icons" { } ''
    mkdir -p $out/share/retrospy
    ${builtins.concatStringsSep "\n" (
      map (e: "cp ${src}/${e}.ico $out/share/retrospy/${e}.ico") executables
    )}
  '';
in
buildDotnetModule {
  inherit version;
  inherit src;
  inherit executables;
  pname = "retrospy";

  nativeBuildInputs = [
    copyDesktopItems
  ];

  desktopItems = map (
    e:
    (makeDesktopItem {
      categories = [ "Utility" ];
      desktopName = "${e}";
      exec = e;
      icon = "${retrospy-icons}/share/retrospy/${e}.ico";
      name = e;
      startupWMClass = e;
    })
  ) executables;

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetDeps = ./deps.json;

  projectFile = [
    "RetroSpyX/RetroSpyX.csproj"
    "GBPemuX/GBPemuX.csproj"
    "GBPUpdaterX2/GBPUpdaterX2.csproj"
    "UsbUpdaterX2/UsbUpdaterX2.csproj"
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Live controller viewer for Nintendo consoles as well as many other retro consoles and computers";
    homepage = "https://retro-spy.com/";
    changelog = "https://github.com/retrospy/RetroSpy/releases/tag/${src.rev}";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.naxdy ];
    platforms = lib.platforms.linux;
    mainProgram = "RetroSpy";
  };
}
