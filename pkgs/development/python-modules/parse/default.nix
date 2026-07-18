{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "parse";
  version = "1.20.2";

  src = fetchFromGitHub {
    owner = "r1chardj0n3s";
    repo = "parse";
    tag = version;
    hash = "sha256-i/H3E/Z8vqt2jLS8BaVHJuD2Fbi7TP7EeOjXAJ16bWg=";
  };

  postPatch = ''
    rm .pytest.ini
  '';

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "parse() is the opposite of format()";
    homepage = "https://github.com/r1chardj0n3s/parse";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ alunduil ];
  };
}
