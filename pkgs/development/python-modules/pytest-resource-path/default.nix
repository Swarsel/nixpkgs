{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  pytest,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-resource-path";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "yukihiko-shinoda";
    repo = "pytest-resource-path";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y/mB5Gmkt3Rt8rRBOFZrWIREnpEiSxf/MChqymXDNws=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ colorama ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_resource_path" ];

  meta = {
    description = "Pytest plugin to provide path for uniform access to test resources";
    homepage = "https://github.com/yukihiko-shinoda/pytest-resource-path";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
