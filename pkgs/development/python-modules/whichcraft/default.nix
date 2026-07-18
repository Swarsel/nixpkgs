{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "whichcraft";
  version = "0.6.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "11yfkzyplizdgndy34vyd5qlmr1n5mxis3a3svxmx8fnccdvknxc";
  };

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    py.test
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Cross-platform cross-python shutil.which functionality";
    homepage = "https://github.com/pydanny/whichcraft";
    changelog = "https://github.com/cookiecutter/whichcraft/blob/${finalAttrs.version}/HISTORY.rst";
    license = lib.licenses.bsd3;
  };
})
