{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "nbxplorer";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "btcpayserver";
    repo = "NBXplorer";
    tag = "v${version}";
    hash = "sha256-X1+UdsKVOC3QpES22p0MG1Rz1oresilBM+b/4I1nCyI=";
  };

  # macOS has a case-insensitive filesystem, so these two can be the same file
  postFixup = ''
    mv $out/bin/{NBXplorer,nbxplorer} || :
  '';

  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  nugetDeps = ./deps.json;
  projectFile = "NBXplorer/NBXplorer.csproj";

  meta = {
    description = "Minimalist UTXO tracker for HD Cryptocurrency Wallets";
    homepage = "https://github.com/btcpayserver/NBXplorer";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kcalvinalvin
      erikarvstedt
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "nbxplorer";
  };
}
