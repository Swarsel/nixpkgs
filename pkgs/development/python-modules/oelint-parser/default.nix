{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecated,
  pytest-cov-stub,
  pytest-forked,
  pytest-random-order,
  pytestCheckHook,
  regex,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "oelint-parser";
  version = "8.11.5";

  src = fetchFromGitHub {
    owner = "priv-kweihmann";
    repo = "oelint-parser";
    tag = finalAttrs.version;
    hash = "sha256-DwbpF1H5fY854YKqB/8ppg6gMS2VhMzoyY8yr/DsfBk=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-forked
    pytest-random-order
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    regex
    deprecated
  ];

  pyproject = true;
  pythonImportsCheck = [ "oelint_parser" ];
  pythonRelaxDeps = [ "regex" ];

  meta = {
    description = "Alternative parser for bitbake recipes";
    homepage = "https://github.com/priv-kweihmann/oelint-parser";
    changelog = "https://github.com/priv-kweihmann/oelint-parser/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ otavio ];
  };
})
