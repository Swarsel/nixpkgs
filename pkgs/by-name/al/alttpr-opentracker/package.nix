{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildDotnetModule,
  dotnetCorePackages,
  fontconfig,
  gtk3,
  icu,
  libice,
  libkrb5,
  libsm,
  libunwind,
  libx11,
  libxi,
  openssl,
  wrapGAppsHook3,
  xinput,
}:
buildDotnetModule rec {
  pname = "opentracker";
  version = "1.8.6";

  src = fetchFromGitHub {
    owner = "trippsc2";
    repo = "opentracker";
    tag = version;
    hash = "sha256-4EBn3BX5tX+yPUjoNFQSls9CwTCd6MpvcBoUKwRndRo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    fontconfig
    gtk3
    icu
    libkrb5
    libunwind
    openssl
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
    "libintl.so.8"
  ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "OpenTracker" ];
  nugetDeps = ./deps.json;
  projectFile = "src/OpenTracker/OpenTracker.csproj";

  runtimeDeps = [
    gtk3
    openssl
    xinput
    libice
    libsm
    libx11
    libxi
  ];

  meta = {
    description = "Tracking application for A Link to the Past Randomizer";
    homepage = "https://github.com/trippsc2/OpenTracker";
    license = lib.licenses.mit;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # deps
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "OpenTracker";
  };
}
