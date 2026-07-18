{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  altcoinSupport ? false,
}:

buildDotnetModule rec {
  pname = "btcpayserver";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "btcpayserver";
    repo = "btcpayserver";
    tag = "v${version}";
    hash = "sha256-u4VNDKLOb6bEkdhRTmnGxyM+2a6mcdWwV1T4+HFK/14=";
  };

  # macOS has a case-insensitive filesystem, so these two can be the same file
  postFixup = ''
    mv $out/bin/{BTCPayServer,btcpayserver} || :
  '';

  buildType = if altcoinSupport then "Altcoins-Release" else "Release";
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetDeps = ./deps.json;
  projectFile = "BTCPayServer/BTCPayServer.csproj";

  meta = {
    description = "Self-hosted, open-source cryptocurrency payment processor";
    homepage = "https://btcpayserver.org";
    changelog = "https://github.com/btcpayserver/btcpayserver/blob/v${version}/Changelog.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kcalvinalvin
      erikarvstedt
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
