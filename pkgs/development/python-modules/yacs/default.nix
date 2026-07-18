{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
  pyyaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "yacs";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "rbgirshick";
    repo = "yacs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nO8FL4tTkfTthXYXxXORLieFwvn780DDxfrxC9EUUJ0=";
  };

  checkPhase = ''
    ${python.interpreter} yacs/tests.py
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pyyaml ];
  pyproject = true;
  pythonImportsCheck = [ "yacs" ];

  meta = {
    description = "Yet Another Configuration System";
    homepage = "https://github.com/rbgirshick/yacs";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
