{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
  versionCheckHook,
}:

buildDotnetModule rec {
  pname = "vrcadvert";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "galister";
    repo = "VrcAdvert";
    tag = "v${version}";
    hash = "sha256-lrRH+BBeVpYVAdFdlsYVxsBOENZseBVoAxb5v9+E7g8=";
  };

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnetFlags = [ "-p:RuntimeFrameworkVersion=${dotnet-runtime.version}" ];
  executables = [ "VrcAdvert" ];
  nugetDeps = ./deps.json;
  versionCheckProgram = "${placeholder "out"}/bin/VrcAdvert";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Advertise your OSC app through OSCQuery";
    homepage = "https://github.com/galister/VrcAdvert";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = lib.platforms.all;
    mainProgram = "VrcAdvert";
  };
}
