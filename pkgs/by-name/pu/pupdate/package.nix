{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
  openssl,
  zlib,
}:

buildDotnetModule rec {
  pname = "pupdate";
  version = "4.14.0";

  src = fetchFromGitHub {
    owner = "mattpannella";
    repo = "pupdate";
    rev = "${version}";
    hash = "sha256-0xjrw0ivSjQ7iQmDF9ZkDhYnbE34qW2uMD4DXvCfBZE=";
  };

  # See https://github.com/NixOS/nixpkgs/pull/196648/commits/0fb17c04fe34ac45247d35a1e4e0521652d9c494
  patches = [ ./add-runtime-identifier.patch ];

  postPatch = ''
    substituteInPlace pupdate.csproj \
      --replace-fail @RuntimeIdentifier@ "${dotnetCorePackages.systemToDotnetRid stdenv.hostPlatform.system}"
  '';

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    zlib
    openssl
  ];

  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;

  dotnetFlags = [
    "-p:PackageRuntime=${dotnetCorePackages.systemToDotnetRid stdenv.hostPlatform.system} -p:TrimMode=partial"
  ];

  executables = [ "pupdate" ];
  nugetDeps = ./deps.json;
  projectFile = "pupdate.csproj";
  selfContainedBuild = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Update utility for the openFPGA cores, firmware, and other stuff on your Analogue Pocket";
    homepage = "https://github.com/mattpannella/pupdate";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "pupdate";
  };
}
