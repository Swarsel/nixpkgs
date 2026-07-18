{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  fetchpatch,
  # Python deps
  mando,
  poetry-core,
  pytest-mock,
  pytestCheckHook,
  tomli,
}:

buildPythonPackage rec {
  pname = "radon";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "rubik";
    repo = "radon";
    rev = "v${version}";
    hash = "sha256-yY+j9kuX0ou/uDoVI/Qfqsmq0vNHv735k+vRl22LwwY=";
  };

  patches = [
    # NOTE: Remove after next release
    (fetchpatch {
      hash = "sha256-WwcfR2ZEWeRiMKdMZAwtZRBcWOqoqpaVTmVo0k+Tn74=";
      url = "https://github.com/rubik/radon/commit/ce5d2daa0a9e0e843059d6f57a8124c64a87a6dc.patch";
    })
  ];

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    mando
    colorama
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  optional-dependencies = {
    toml = [ tomli ];
  };

  pyproject = true;
  pythonImportsCheck = [ "radon" ];

  pythonRelaxDeps = [
    "mando"
  ];

  meta = {
    description = "Various code metrics for Python code";
    homepage = "https://radon.readthedocs.org";
    changelog = "https://github.com/rubik/radon/blob/v${version}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ t4ccer ];
    mainProgram = "radon";
  };
}
