{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  fields,
  process-tests,
  pytestCheckHook,
  setuptools,
  tornado,
}:

buildPythonPackage rec {
  pname = "aspectlib";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pLRhudoLUxrry5PvzePegIpyxgIm3Y2QLEZ9E/r3zpI=";
  };

  patches = [
    # https://github.com/ionelmc/python-aspectlib/pull/25
    (fetchpatch {
      hash = "sha256-gtPFtwDsGIMkHTyuoiLk+SAGgB2Wyx/Si9HIdoIsvI8=";
      name = "darwin-compat.patch";
      url = "https://github.com/ionelmc/python-aspectlib/commit/ef2c12304f08723dc8e79d1c59bc32c946d758dc.patch";
    })
  ];

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ fields ];

  nativeCheckInputs = [
    process-tests
    pytestCheckHook
    tornado
  ];

  __darwinAllowLocalNetworking = true;
  pyproject = true;
  pytestFlags = [ "-Wignore::DeprecationWarning" ];

  pythonImportsCheck = [
    "aspectlib"
    "aspectlib.contrib"
    "aspectlib.debug"
    "aspectlib.test"
  ];

  meta = {
    description = "Aspect-oriented programming, monkey-patch and decorators library";
    homepage = "https://github.com/ionelmc/python-aspectlib";
    changelog = "https://github.com/ionelmc/python-aspectlib/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
