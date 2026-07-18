{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dill,
  hatchling,
  pytestCheckHook,
  pythonAtLeast,
}:

buildPythonPackage rec {
  pname = "latexify-py";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "google";
    repo = "latexify_py";
    tag = "v${version}";
    hash = "sha256-tyBIOIVRSNrhO1NOD7Zqmiksrvrm42DUY4w1IocVRl4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd src
  '';

  build-system = [ hatchling ];
  dependencies = [ dill ];
  # AttributeError: module 'ast' has no attribute 'Num'
  # https://docs.python.org/3/whatsnew/3.14.html#id9
  disabled = pythonAtLeast "3.14";
  pyproject = true;
  pythonImportsCheck = [ "latexify" ];

  meta = {
    description = "Generates LaTeX math description from Python functions";
    homepage = "https://github.com/google/latexify_py";
    changelog = "https://github.com/google/latexify_py/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ prusnak ];
  };
}
