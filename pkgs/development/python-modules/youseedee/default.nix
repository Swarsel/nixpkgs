{
  lib,
  buildPythonPackage,
  fetchPypi,
  filelock,
  platformdirs,
  replaceVars,
  requests,
  setuptools,
  setuptools-scm,
  unicode-character-database,
}:

buildPythonPackage rec {
  pname = "youseedee";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-b5gxBIr/mowzlG4/N0C22S1XTq0NAGTq1/+iMUfxD18=";
  };

  patches = [
    # Load data files from the unicode-character-database package instead of
    # downloading them from the internet. (nixpkgs-specific, not upstreamable)
    (replaceVars ./0001-use-packaged-unicode-data.patch {
      ucd_dir = "${unicode-character-database}/share/unicode";
    })
  ];

  # Package has no unit tests, but we can check an example as per README.rst:
  checkPhase = ''
    runHook preCheck
    python -m youseedee 0x078A | grep -qE "Block\s+Thaana"
    runHook postCheck
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    filelock
    requests
    platformdirs
  ];

  pyproject = true;

  meta = {
    description = "Python library for querying the Unicode Character Database";
    homepage = "https://github.com/simoncozens/youseedee";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}
