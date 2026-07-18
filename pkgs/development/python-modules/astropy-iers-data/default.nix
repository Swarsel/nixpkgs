{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "astropy-iers-data";
  version = "0.2026.6.22.1.23.34";

  src = fetchFromGitHub {
    owner = "astropy";
    repo = "astropy-iers-data";
    tag = "v${finalAttrs.version}";
    hash = "sha256-q3uW3G3WTHpaRC54tO7ytmSg65SMaOQKO5KbqaSxeq4=";
  };

  # no tests
  doCheck = false;

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;
  pythonImportsCheck = [ "astropy_iers_data" ];

  meta = {
    description = "IERS data maintained by @astrofrog and astropy.utils.iers maintainers";
    homepage = "https://github.com/astropy/astropy-iers-data";
    changelog = "https://github.com/astropy/astropy-iers-data/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
