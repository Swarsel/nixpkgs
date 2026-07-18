{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "boolean-py";
  version = "5.0";

  src = fetchFromGitHub {
    owner = "bastikr";
    repo = "boolean.py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h5iHcdN77ZRGMJnSJLoYkRTY1TeJ3yQ1eF193HKsNqU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "boolean" ];

  meta = {
    description = "Implements boolean algebra in one module";
    homepage = "https://github.com/bastikr/boolean.py";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
})
