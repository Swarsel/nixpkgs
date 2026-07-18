{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "click-threading";
  version = "0.5.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-rc/mI8AqWVwQfDFAcvZ6Inj+TrQLcsDRoskDzHivNDk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf docs
  '';

  build-system = [ setuptools ];
  dependencies = [ click ];
  pyproject = true;
  pythonImportsCheck = [ "click_threading" ];

  meta = {
    description = "Multithreaded Click apps made easy";
    homepage = "https://github.com/click-contrib/click-threading/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
