{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  cpe,
  jsonschema,
  python-dateutil,
  requests,
  setuptools,
  simplejson,
  stix2-patterns,
}:

buildPythonPackage (finalAttrs: {
  pname = "stix2-validator";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "oasis-open";
    repo = "cti-stix-validator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w9SlRspt5tRLdqqEr6UJ+cmq3KM08cN9BqMvdSYay0Y=";
  };

  # Tests need more work
  # Exception: Could not deserialize ATN with version  (expected 4).
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    colorama
    cpe
    jsonschema
    python-dateutil
    requests
    simplejson
    stix2-patterns
  ];

  pyproject = true;

  # nativeCheckInputs = [ pytestCheckHook ];
  meta = {
    description = "Validator for STIX 2.0 JSON normative requirements and best practices";
    homepage = "https://github.com/oasis-open/cti-stix-validator/";
    changelog = "https://github.com/oasis-open/cti-stix-validator/blob/${finalAttrs.src.tag}/CHANGELOG";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
