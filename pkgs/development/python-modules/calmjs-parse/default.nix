{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ply,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "calmjs-parse";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "calmjs";
    repo = "calmjs.parse";
    tag = version;
    hash = "sha256-OX3031omx9PdrVeNbekWzJKrrrKleP7q7yDosKsvH8U=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "env['PYTHONPATH'] = 'src'" "env['PYTHONPATH'] += ':src'"
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    setuptools
    ply
  ];

  pyproject = true;

  pythonImportsCheck = [
    "calmjs.parse"
    "calmjs.parse.asttypes"
    "calmjs.parse.parsers"
    "calmjs.parse.rules"
    "calmjs.parse.sourcemap"
    "calmjs.parse.unparsers.es5"
    "calmjs.parse.walkers"
  ];

  meta = {
    description = "Various parsers for ECMA standards";
    homepage = "https://github.com/calmjs/calmjs.parse";
    changelog = "https://github.com/calmjs/calmjs.parse/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
