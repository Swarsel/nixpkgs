{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  frozendict,
  numpy,
  setuptools,
  sympy,
  wheel,
}:

buildPythonPackage rec {
  pname = "einx";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "fferflo";
    repo = "einx";
    rev = "v${version}";
    hash = "sha256-xYnlIN+O2s0tTBpqiGiiA6p6QpF5olPFbYaiLPT8B1s=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    numpy
    sympy
    frozendict
  ];

  pyproject = true;

  pythonImportsCheck = [
    "einx"
  ];

  meta = {
    description = "Universal Tensor Operations in Einstein-Inspired Notation for Python";
    homepage = "https://github.com/fferflo/einx";
    changelog = "https://github.com/fferflo/einx/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
