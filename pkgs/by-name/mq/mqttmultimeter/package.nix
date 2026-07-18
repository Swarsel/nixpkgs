{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnet-runtime_8,
  dotnetCorePackages,
  libglvnd,
  makeDesktopItem,
}:

buildDotnetModule rec {
  pname = "mqttmultimeter";
  version = "1.8.2.272";

  src = fetchFromGitHub {
    owner = "chkr1011";
    repo = "mqttMultimeter";
    rev = "v" + version;
    hash = "sha256-vL9lmIhNLwuk1tmXLKV75xAhktpdNOb0Q4ZdvLur5hw=";
  };

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  postInstall = ''
    rm -rf $out/lib/${lib.toLower pname}/runtimes/{*musl*,win*}
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Network" ];
      comment = meta.description;
      desktopName = meta.mainProgram;
      exec = meta.mainProgram;
      genericName = meta.description;
      icon = meta.mainProgram;
      name = meta.mainProgram;
      startupNotify = true;
      type = "Application";
    })
  ];

  dotnet-runtime = dotnet-runtime_8;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "mqttMultimeter" ];
  nugetDeps = ./deps.json;
  projectFile = [ "mqttMultimeter.sln" ];

  runtimeDeps = [
    libglvnd
  ];

  sourceRoot = "${src.name}/Source";

  meta = {
    description = "MQTT traffic monitor";
    homepage = "https://github.com/chkr1011/mqttMultimeter";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.linux;
    mainProgram = builtins.head executables;
  };
}
