{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "BinaryObjectScanner";
  version = "3.3.4";

  src = fetchFromGitHub {
    owner = "SabreTools";
    repo = "BinaryObjectScanner";
    tag = version;
    hash = "sha256-FiSBJO4ic/KjokUEP0uB1WNfFRcOWH/x0y9yJMKnl4Q=";
  };

  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnetFlags = [ "-p:TargetFramework=net9.0" ];

  executables = [
    "ProtectionScan"
    "ExtractionTool"
  ];

  nugetDeps = ./deps.json;

  projectFile = [
    "ProtectionScan/ProtectionScan.csproj"
    "ExtractionTool/ExtractionTool.csproj"
  ];

  meta = {
    description = "C# protection, packer, and archive scanning library. Provides ProtectionScan and ExtractionTool";
    homepage = "https://github.com/SabreTools/BinaryObjectScanner";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hughobrien ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = "ProtectionScan";
  };
}
