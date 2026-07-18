{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyparsing,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "kinparse";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "xesscorp";
    repo = "kinparse";
    tag = version;
    hash = "sha256-170e2uhqpk6u/hahivWYubr3Ptb8ijymJSxhxrAfuyI=";
  };

  # Remove python2 build support as it breaks python >= 3.13
  postPatch = ''
    substituteInPlace setup.cfg \
      --replace-fail "universal = 1" "universal = 0"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    substituteInPlace tests/test_kinparse.py \
      --replace-fail "data/" "$src/tests/data/"
  '';

  build-system = [ setuptools ];
  dependencies = [ pyparsing ];
  pyproject = true;
  pythonImportsCheck = [ "kinparse" ];
  pythonRemoveDeps = [ "future" ];

  meta = {
    description = "Parser for KiCad EESCHEMA netlists";
    homepage = "https://github.com/xesscorp/kinparse";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthuszagh ];
    mainProgram = "kinparse";
  };
}
