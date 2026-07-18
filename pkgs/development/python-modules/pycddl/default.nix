{
  lib,
  buildPythonPackage,
  cbor2,
  fetchPypi,
  hypothesis,
  psutil,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "pycddl";
  version = "0.6.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aUa6Q3e1RwvWN0NPqbJtWW3o/yzJxUc0g7gUGKUlOXo=";
  };

  postPatch = ''
    # We don't place pytest-benchmark in the closure because we have no
    # intention of running the benchmarks.  Make sure pip doesn't fail as a
    # result of it being missing by removing it from the requirements list.
    sed -i -e /pytest-benchmark/d requirements-dev.txt

    # Now that we've gotten rid of pytest-benchmark we need to get rid of the
    # benchmarks too, otherwise they fail at import time due to the missing
    # dependency.
    rm tests/test_benchmarks.py
  '';

  nativeBuildInputs = with rustPlatform; [
    maturinBuildHook
    cargoSetupHook
  ];

  env.PYO3_USE_ABI3_FORWARD_COMPATIBILITY = 1;

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    psutil
    cbor2
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-cEpvkSqe/wRCxEajmM148jbo6a346x2t81pMRpKEJyE=";
  };

  disabledTests = [
    # flaky
    "test_memory_usage"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycddl" ];

  meta = {
    description = "Python bindings for the Rust cddl crate";
    homepage = "https://gitlab.com/tahoe-lafs/pycddl";
    changelog = "https://gitlab.com/tahoe-lafs/pycddl/-/tree/v${version}#release-notes";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.exarkun ];
  };
}
