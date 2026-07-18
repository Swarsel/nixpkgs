{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildDotnetModule,
  dotnetCorePackages,
  ffmpeg,
  gtk3,
  icu,
  krb5,
  makeWrapper,
  mpg123,
  nix-update-script,
  openssl,
  versionCheckHook,
  webkitgtk_4_1,
  zlib,
}:
buildDotnetModule rec {
  pname = "undercut-f1";
  version = "4.0.89";

  src = fetchFromGitHub {
    owner = "JustAman62";
    repo = "undercut-f1";
    tag = "v${version}";
    hash = "sha256-JAyOSoiaV+US6liqfci0gIgULdgwd7o8VtlJZfGPHFc=";
  };

  postPatch = ''
      rm -f .config/dotnet-tools.json
      substituteInPlace UndercutF1.Console/UndercutF1.Console.csproj --replace-fail \
        "<EnableCompressionInSingleFile>true</EnableCompressionInSingleFile>" \
        "<EnableCompressionInSingleFile>false</EnableCompressionInSingleFile><DebugType>none</DebugType>
    <DebugSymbols>false</DebugSymbols>"
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    gtk3
    webkitgtk_4_1
    openssl
    krb5
    icu
    zlib
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  installCheckPhase = ''
    $out/bin/undercutf1 --version | grep -q "${version}"
  '';

  postFixup = ''
    wrapProgram $out/bin/undercutf1 \
      --prefix PATH : ${
        lib.makeBinPath [
          ffmpeg
          mpg123
        ]
      }
  '';

  dotnet-runtime = dotnetCorePackages.sdk_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  dotnetBuildFlags = [
    "-p:DebugType=None"
    "-p:IncludeNativeLibrariesForSelfExtract=true"
    "-p:IncludeAllContentForSelfExtract=true"
    "-p:OverridePackageVersion=${version}"
    "-p:PublicRelease=true"
  ];

  dotnetPublishFlags = [
    "-p:PublishTrimmed=false"
    "-p:OverridePackageVersion=${version}"
  ];

  executables = [ "undercutf1" ];
  nugetDeps = ./deps.json;
  projectFile = "UndercutF1.Console/UndercutF1.Console.csproj";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source F1 Live Timing TUI client with replay, driver tracker and team-radio transcription";
    homepage = "https://github.com/JustAman62/undercut-f1";
    changelog = "https://github.com/JustAman62/undercut-f1/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ linuxmobile ];
    platforms = lib.platforms.linux;
    mainProgram = "undercutf1";
  };
}
