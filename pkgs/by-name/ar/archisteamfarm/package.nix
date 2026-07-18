{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  callPackage,
  dotnetCorePackages,
  libkrb5,
  openssl,
  zlib,
}:

let
  plugins = [
    "ArchiSteamFarm.OfficialPlugins.ItemsMatcher"
    "ArchiSteamFarm.OfficialPlugins.MobileAuthenticator"
    "ArchiSteamFarm.OfficialPlugins.Monitoring"
    "ArchiSteamFarm.OfficialPlugins.SteamTokenDumper"
  ];
in
buildDotnetModule rec {
  pname = "archisteamfarm";
  # nixpkgs-update: no auto update
  version = "6.3.6.1";

  src = fetchFromGitHub {
    owner = "JustArchiNET";
    repo = "ArchiSteamFarm";
    tag = version;
    hash = "sha256-C0n3e/t1Bq02vlrF/KyT7vlhtNDIbAsg9zAk9aKZ5/g=";
  };

  # times out when trying to connect to something even with relaxed sandbox
  doCheck = stdenv.hostPlatform.isLinux;

  preInstall = ''
    dotnetProjectFiles=(ArchiSteamFarm)

    # A mutable path, with this directory tree must be set. By default, this would point at the nix store causing errors.
    makeWrapperArgs+=(
      --run 'mkdir -p ~/.config/archisteamfarm/{config,logs,plugins}'
      --set "ASF_PATH" "~/.config/archisteamfarm"
    )
  '';

  postInstall = ''
    buildPlugin() {
      echo "Publishing plugin $1"
      dotnet publish $1 -p:ContinuousIntegrationBuild=true -p:Deterministic=true \
        --output $out/lib/ArchiSteamFarm/plugins/$1 --configuration Release \
        --no-restore --no-build --runtime $dotnetRuntimeIds \
        $dotnetFlags $dotnetInstallFlags
    }

  ''
  + lib.concatMapStrings (p: "buildPlugin ${p}\n") plugins
  + ''

    chmod +x $out/lib/ArchiSteamFarm/ArchiSteamFarm.dll
    wrapDotnetProgram $out/lib/ArchiSteamFarm/ArchiSteamFarm.dll $out/bin/ArchiSteamFarm
    substituteInPlace $out/bin/ArchiSteamFarm \
      --replace-fail "exec " "exec dotnet "
  '';

  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  dotnetBuildFlags = [
    "--framework=net10.0"
  ];

  dotnetFlags = [
    # useAppHost doesn't explicitly disable this
    "-p:UseAppHost=false"
    "-p:RuntimeIdentifiers="
  ];

  dotnetInstallFlags = dotnetBuildFlags;
  enableParallelBuilding = false;
  executable = "ArchiSteamFarm";
  installPath = "${placeholder "out"}/lib/ArchiSteamFarm";
  nugetDeps = ./deps.json;

  projectFile = [
    "ArchiSteamFarm"
  ]
  ++ plugins;

  runtimeDeps = [
    libkrb5
    zlib
    openssl
  ];

  testProjectFile = "ArchiSteamFarm.Tests";
  useAppHost = false;

  passthru = {
    ui = callPackage ./web-ui { };
    # nix-shell maintainers/scripts/update.nix --argstr package archisteamfarm
    updateScript = ./update.sh;
  };

  meta = {
    description = "Application with primary purpose of idling Steam cards from multiple accounts simultaneously";
    homepage = "https://github.com/JustArchiNET/ArchiSteamFarm";
    changelog = "https://github.com/JustArchiNET/ArchiSteamFarm/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    mainProgram = "ArchiSteamFarm";
  };
}
