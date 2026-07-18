{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  regex,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-jsonpath";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "jg-rp";
    repo = "python-jsonpath";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7kXDGm+pV0daeMEGW/hVb/U69svLFgZfZKklVgV+EJ4=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.strict;

  build-system = [ hatchling ];

  optional-dependencies = {
    strict = [
      # FIXME package iregexp-check
      regex
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "jsonpath" ];

  meta = {
    description = "Flexible JSONPath engine for Python with JSON Pointer and JSON Patch";
    homepage = "https://github.com/jg-rp/python-jsonpath";
    changelog = "https://github.com/jg-rp/python-jsonpath/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
