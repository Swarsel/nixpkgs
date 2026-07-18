{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchPnpmDeps,
  hatch-vcs,
  hatchling,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
buildPythonPackage rec {
  pname = "yt-dlp-ejs";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "ejs";
    tag = version;
    hash = "sha256-+tOA9sPk0BGJHFQCoAC8y5Bz3UcjgIPDQ8WDPkRlW5k=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      pnpm
      ;

    fetcherVersion = 3;
    hash = "sha256-4qMOAl9Dbe1oYSRIeP7oPcV/+P8NLdIYvSNxaz0h+Z0=";
  };

  pyproject = true;
  pythonImportsCheck = [ "yt_dlp_ejs" ];

  meta = {
    description = "External JavaScript for yt-dlp supporting many runtimes";
    homepage = "https://github.com/yt-dlp/ejs/";
    changelog = "https://github.com/yt-dlp/ejs/releases/tag/${version}";

    license = with lib.licenses; [
      unlicense
      mit
      isc
    ];

    maintainers = with lib.maintainers; [
      SuperSandro2000
      _4evy
    ];
  };
}
