{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pytestCheckHook,
  pytz,
  setuptools,
  tzdata,
}:

buildPythonPackage rec {
  pname = "pytz-deprecation-shim";
  version = "0.1.0.post0";

  src = fetchPypi {
    inherit version;
    sha256 = "af097bae1b616dde5c5744441e2ddc69e74dfdcb0c263129610d85b87445a59d";
    pname = "pytz_deprecation_shim";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ tzdata ];
  # https://github.com/pganssle/pytz-deprecation-shim/issues/27
  # https://github.com/pganssle/pytz-deprecation-shim/issues/30
  # The test suite is just very flaky and breaks all the time
  doCheck = false;

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pytz
  ];

  pyproject = true;

  meta = {
    description = "Shims to make deprecation of pytz easier";
    homepage = "https://github.com/pganssle/pytz-deprecation-shim";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
