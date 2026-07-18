{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
  openssl,
  zlib,
}:

buildDotnetModule rec {
  pname = "ps3-disc-dumper";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "13xforever";
    repo = "ps3-disc-dumper";
    tag = "v${version}";
    hash = "sha256-JF+qN4YR2thE/ByUjvDMDgMtPuD3jKZL0qGvPBCxYQ4=";
  };

  buildType = "Linux";
  dotnet-runtime = dotnetCorePackages.sdk_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnetRestoreFlags = [ "-p:Configuration=${buildType}" ];
  nugetDeps = ./deps.json;
  projectFile = "UI.Avalonia/UI.Avalonia.csproj";

  runtimeDeps = [
    zlib
    openssl
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Handy utility to make decrypted PS3 disc dumps";
    homepage = "https://github.com/13xforever/ps3-disc-dumper";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      evanjs
      gepbird
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "ps3-disc-dumper";
  };
}
