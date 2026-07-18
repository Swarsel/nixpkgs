{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildDotnetModule,
  buildNpmPackage,
  bun,
  dotnetCorePackages,
  icu,
  krb5,
  openssl,
}:

let
  # for update.sh easy to handle
  ngclientVersion = "0.0.226";
  ngclientRev = "2cc3e2e088ddb4691bb389b0afa89287d399340e";
  ngclientHash = "sha256-uMWOunSaV9HNhgH65P2boangZFe/9NCRb5BBqXv9TI0=";

  # from Duplicati/Server/webroot/ngclient/package.json
  ngclient = buildNpmPackage {
    pname = "ngclient";
    version = ngclientVersion;

    src = fetchFromGitHub {
      owner = "duplicati";
      repo = "ngclient";
      rev = ngclientRev;
      hash = ngclientHash;
    };

    nativeBuildInputs = [ bun ];
    npmDepsHash = "sha256-89l/1v8dncwImDgiQic2VN65K/dxIkEPCrsHCty2VV0=";

    env = {
      CI = "true";
      NG_CLI_ANALYTICS = "false";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/ngclient/* $out/

      runHook postInstall
    '';

    postInstall = ''
      substituteInPlace $out/browser/index.html \
          --replace-fail '<base href="/">' '<base href="/ngclient/">'
    '';

    npmBuildScript = "build:prod";
  };
in
buildDotnetModule rec {
  pname = "duplicati";
  version = "2.3.0.4";

  src = fetchFromGitHub {
    owner = "duplicati";
    repo = "duplicati";
    tag = "v${version}_${channel}_${buildDate}";
    hash = "sha256-pVfcD7bIlZ/ZsMNwjPcg+DY6YFNm191ngEm5SrDukSw=";
    stripRoot = true;
  };

  postPatch = ''
    sed -i '/Duplicati.ShellExtension.csproj/d' Duplicati.slnx

    rm -rf Duplicati/Server/webroot/ngclient
    ln -s ${ngclient}/browser Duplicati/Server/webroot/ngclient
  '';

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [
    icu
    openssl
    krb5
  ];

  postFixup = ''
    mv $out/bin/Duplicati.Agent $out/bin/duplicati-agent
    mv $out/bin/Duplicati.GUI.TrayIcon $out/bin/duplicati
    mv $out/bin/Duplicati.Server $out/bin/duplicati-server
    cp $out/bin/duplicati-server $out/lib/duplicati/duplicati-server
    mv $out/bin/Duplicati.Service $out/bin/duplicati-service
    mv $out/bin/Duplicati.CommandLine $out/bin/duplicati-cli
    mv $out/bin/Duplicati.CommandLine.SyncTool $out/bin/duplicati-sync-tool
    mv $out/bin/Duplicati.CommandLine.SourceTool $out/bin/duplicati-source-tool
    mv $out/bin/Duplicati.CommandLine.DatabaseTool $out/bin/duplicati-database-tool
    mv $out/bin/Duplicati.CommandLine.SharpAESCrypt $out/bin/duplicati-aescrypt
    mv $out/bin/Duplicati.CommandLine.AutoUpdater $out/bin/duplicati-autoupdater
    mv $out/bin/Duplicati.CommandLine.BackendTester $out/bin/duplicati-backend-tester
    mv $out/bin/Duplicati.CommandLine.BackendTool $out/bin/duplicati-backend-tool
    mv $out/bin/Duplicati.CommandLine.RecoveryTool $out/bin/duplicati-recovery-tool
    mv $out/bin/Duplicati.CommandLine.SecretTool $out/bin/duplicati-secret-tool
    mv $out/bin/Duplicati.CommandLine.ServerUtil $out/bin/duplicati-server-util
    mv $out/bin/Duplicati.CommandLine.Snapshots $out/bin/duplicati-snapshots
  '';

  autoPatchelfIgnoreMissingDeps = lib.optionals (!stdenv.hostPlatform.isMusl) [
    "libc.musl-x86_64.so.1"
    "libc.musl-aarch64.so.1"
    "libc.musl-armv7.so.1"
  ];

  buildDate = "2026-07-09";
  channel = "stable";
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  enableParallelBuilding = false;

  executables = [
    "Duplicati.Agent"
    "Duplicati.CommandLine"
    "Duplicati.CommandLine.AutoUpdater"
    "Duplicati.CommandLine.BackendTester"
    "Duplicati.CommandLine.BackendTool"
    "Duplicati.CommandLine.DatabaseTool"
    "Duplicati.CommandLine.RecoveryTool"
    "Duplicati.CommandLine.SecretTool"
    "Duplicati.CommandLine.ServerUtil"
    "Duplicati.CommandLine.SharpAESCrypt"
    "Duplicati.CommandLine.Snapshots"
    "Duplicati.CommandLine.SourceTool"
    "Duplicati.CommandLine.SyncTool"
    "Duplicati.GUI.TrayIcon"
    "Duplicati.Server"
    "Duplicati.Service"
  ];

  nugetDeps = ./deps.json;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Free backup client that securely stores encrypted, incremental, compressed backups on cloud storage services and remote file servers";
    homepage = "https://www.duplicati.com/";
    license = lib.licenses.lgpl21;

    maintainers = with lib.maintainers; [
      nyanloutre
      bot-wxt1221
      puiyq
    ];
    # platforms inherited from dotnet-sdk.
  };
}
