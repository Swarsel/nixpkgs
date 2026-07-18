{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fedora-messaging,
  fqdn,
  jsonschema,
  pytestCheckHook,
  rfc3987,
  setuptools,
  strict-rfc3339,
}:

buildPythonPackage (finalAttrs: {
  pname = "weblate-schemas";
  version = "2026.4";

  src = fetchFromGitHub {
    owner = "WeblateOrg";
    repo = "weblate_schemas";
    tag = finalAttrs.version;
    hash = "sha256-OPuhRsUmVte54UPNna76N5Kbg1Tl7p8OdKbE6VHWcvg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    fedora-messaging
  ]
  ++ jsonschema.optional-dependencies.format;

  build-system = [ setuptools ];

  dependencies = [
    jsonschema
  ];

  pyproject = true;
  pythonImportsCheck = [ "weblate_schemas" ];

  meta = {
    description = "Schemas used by Weblate";
    homepage = "https://github.com/WeblateOrg/weblate_schemas";
    changelog = "https://github.com/WeblateOrg/weblate_schemas/blob/${finalAttrs.version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };

})
