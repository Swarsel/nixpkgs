{
  lib,
  fetchurl,
  buildPythonPackage,
  fetchPypi,
  pypblib,
  pytestCheckHook,
  setuptools,
  six,
}:
let
  kissat404src = fetchurl {
    hash = "sha256-v+k+qmMjtIAR5LH890s/LiD53lRHZ+coAJ5bIBgpYZM=";
    url = "https://github.com/arminbiere/kissat/archive/refs/tags/rel-4.0.4.tar.gz";
  };
  minisatepsrc = fetchurl {
    hash = "sha256-eS5+wPrcZ00DRZMaJp4yZOZ1uz72Auin6FK6G2SId64=";
    url = "https://github.com/hchenqide/minisat/archive/90305f7b9ab9c9c9c560238f16b47c26506d0750.zip";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "python-sat";
  version = "1.9.dev5";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-OxH2AQbusuv5aB/t85nrNOXAuyCfNFZRvMFMWFfmdhg=";
    pname = "python_sat";
  };

  propagatedBuildInputs = [
    six
    pypblib
  ];

  preBuild = ''
    export MAKEFLAGS="-j$NIX_BUILD_CORES"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  # Due to `python -m pytest` appending the local directory to `PYTHONPATH`,
  # importing `pysat.examples` in the tests fails. Removing the `pysat`
  # directory fixes since then only the installed version in `$out` is
  # imported, which has `pysat.examples` correctly installed.
  # See https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    rm -r pysat
  '';

  build-system = [ setuptools ];

  # The kissat source archive is not included in the repo and pysat attempts to
  # download it at build time. We therefore prefetch and link it.
  prePatch = ''
    ln -s ${kissat404src} solvers/kissat404.tar.gz
    ln -s ${minisatepsrc} solvers/minisatep.zip
  '';

  pyproject = true;

  pythonImportsCheck = [
    "pysat"
    "pysat.examples"
    "pysat.allies"
  ];

  meta = {
    description = "Toolkit for SAT-based prototyping in Python (without optional dependencies)";
    homepage = "https://github.com/pysathq/pysat";
    changelog = "https://pysathq.github.io/updates/";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.marius851000
      lib.maintainers.chrjabs
    ];

    platforms = lib.platforms.all;
  };
})
