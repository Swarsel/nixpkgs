{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "PS2PatchElf";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "CaptainSwag101";
    repo = "PS2PatchElf";
    tag = "v${version}";
    hash = "sha256-iQL3tT71UOEFIYBdf9BNLUM4++Fm9qEhr77NkMCZdrU=";
  };

  patches = [
    ./patches/target_net8.0.patch
    ./patches/fix_arg_check.patch
  ];

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnetFlags = [ "-p:TargetFramework=net8.0" ];
  nugetDeps = ./deps.json;
  projectFile = "PS2PatchElf/PS2PatchElf.csproj";

  meta = {
    description = "Very basic tool for converting PCSX2 .pnach cheats to game executable patches";
    homepage = "https://github.com/CaptainSwag101/PS2PatchElf/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.gigahawk ];
    mainProgram = "PS2PatchElf";
  };
}
