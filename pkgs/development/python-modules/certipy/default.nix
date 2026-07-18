{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  flask,
  pytestCheckHook,
  requests,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "certipy";
  version = "0.2.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-TocB5qLygeehVMLzaM/07fN0AJCE0peIy+jDg4iXeE8=";
  };

  nativeCheckInputs = [
    flask
    pytestCheckHook
    requests
  ];

  build-system = [ setuptools-scm ];
  dependencies = [ cryptography ];
  pyproject = true;
  pythonImportsCheck = [ "certipy" ];

  meta = {
    description = "Utility to create and sign CAs and certificates";
    homepage = "https://github.com/LLNL/certipy";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ isgy ];
    mainProgram = "certipy";
  };
})
