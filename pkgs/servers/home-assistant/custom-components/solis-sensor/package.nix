{
  lib,
  fetchFromGitHub,
  aiofiles,
  buildHomeAssistantComponent,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "hultenvp";
    repo = "solis-sensor";
    rev = "v${version}";
    hash = "sha256-53bRd+Zz46Mxiycpa8h4DXc9wUFmkczNtpteTkci4Q0=";
  };

  dependencies = [ aiofiles ];
  domain = "solis";
  dontCheckManifest = true; # aiofiles version constraint mismatch
  owner = "hultenvp";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Home Assistant integration for the SolisCloud PV Monitoring portal via SolisCloud API";
    homepage = "https://github.com/hultenvp/solis-sensor";
    changelog = "https://github.com/hultenvp/solis-sensor/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
