{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
  nixosTests,
  openssl,
  zlib,
}:
buildDotnetModule rec {
  pname = "wasabibackend";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "WalletWasabi";
    repo = "WalletWasabi";
    tag = "v${version}";
    hash = "sha256-vOvNumR/0agf9Mof0UD3KjJVgN18y6R/OrgLOXwL3K8=";
  };

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    zlib
  ];

  postFixup = ''
    mv $out/bin/WalletWasabi.Backend $out/bin/WasabiBackend
  '';

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "WalletWasabi.Backend" ];
  nugetDeps = ./deps.json;
  projectFile = "WalletWasabi.Backend/WalletWasabi.Backend.csproj";

  runtimeDeps = [
    openssl
    zlib
  ];

  passthru = {
    tests = {
      inherit (nixosTests) wasabibackend;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Backend for the Wasabi Wallet";
    homepage = "https://wasabiwallet.io/";
    changelog = "https://github.com/WalletWasabi/WalletWasabi/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode # contains binaries in WalletWasabi/Microservices/Binaries
      fromSource
    ];

    maintainers = with lib.maintainers; [
      mmahut
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "WasabiBackend";
  };
}
