{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "disposable-email-domains";
  version = "0.0.216";

  # No tags on GitHub
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-b9qSbIJ3wrINFnfhkzKu60WX7w6l860jjZ/klkeIhY4=";
    pname = "disposable_email_domains";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "disposable_email_domains" ];

  meta = {
    description = "Set of disposable email domains";
    homepage = "https://github.com/disposable-email-domains/disposable-email-domains";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
