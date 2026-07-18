{
  lib,
  attrs,
  buildPythonPackage,
  deprecated,
  fetchPypi,
  hatch-vcs,
  hatchling,
  hepunits,
  pandas,
  pytestCheckHook,
  tabulate,
}:

buildPythonPackage rec {
  pname = "particle";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SRRd7By1BEsH8+jpAigPoFCVD6hFsFgAPmneUZu1BJI=";
  };

  postPatch = ''
    # Disable benchmark tests, so we won't need pytest-benchmark and pytest-cov
    # as dependencies
    substituteInPlace pyproject.toml \
      --replace '"--benchmark-disable",' ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    tabulate
    pandas
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    attrs
    deprecated
    hepunits
  ];

  disabledTestPaths = [
    # Requires pytest-benchmark and pytest-cov which we want to avoid using, as
    # it doesn't really test functionality.
    "tests/particle/test_performance.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "particle" ];

  meta = {
    description = "Package to deal with particles, the PDG particle data table and others";
    homepage = "https://github.com/scikit-hep/particle";
    changelog = "https://github.com/scikit-hep/particle/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
