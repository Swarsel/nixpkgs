{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:
buildDotnetModule (finalAttrs: {
  pname = "n-m3u8dl-re";
  version = "0.5.1-beta";

  src = fetchFromGitHub {
    owner = "nilaoda";
    repo = "N_m3u8DL-RE";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-LLBlSalYqOEPTttEMK/pBoxwiHXeAxFIUm/yuLb1WRo=";
  };

  patches = [
    # error: PublishTrimmed is implied by native compilation and cannot be disabled
    ./publish-fix.patch
  ];

  postFixup = ''
    ln -s $out/bin/N_m3u8DL-RE $out/bin/n-m3u8dl-re
  '';

  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  # from openutau/default.nix
  # [...]/Microsoft.NET.Sdk/targets/Microsoft.NET.Sdk.targets(248,5): error MSB4018: The "GenerateDepsFile" task failed unexpectedly. [[...]/N_m3u8DL-RE.Common.csproj]
  # [...]/Microsoft.NET.Sdk/targets/Microsoft.NET.Sdk.targets(248,5): error MSB4018: System.IO.IOException: The process cannot access the file '[...]/N_m3u8DL-RE.Common.deps.json' because it is being used by another process. [[...]/N_m3u8DL-RE.Common.csproj]
  enableParallelBuilding = false;
  executables = [ "N_m3u8DL-RE" ];
  nugetDeps = ./deps.json;
  projectFile = "src/N_m3u8DL-RE.sln";

  meta = {
    description = "Cross-Platform, modern and powerful stream downloader for MPD/M3U8/ISM";
    homepage = "https://github.com/nilaoda/N_m3u8DL-RE";
    changelog = "https://github.com/nilaoda/N_m3u8DL-RE/releases/tag/v{finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phanirithvij ];
    platforms = lib.platforms.unix;
    mainProgram = "n-m3u8dl-re";
  };
})
