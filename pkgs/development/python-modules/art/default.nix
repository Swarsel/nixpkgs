{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "art";
  version = "6.5";

  src = fetchFromGitHub {
    owner = "sepandhaghighi";
    repo = "art";
    tag = "v${version}";
    hash = "sha256-ub+hvxYRZznql/GZjA6QXrdHUbM+QCVEYiQfQ6IOJKE=";
  };

  # TypeError: art() missing 1 required positional argument: 'artname'
  checkPhase = ''
    runHook preCheck

    $out/bin/art
    $out/bin/art test
    $out/bin/art test2

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "art" ];

  meta = {
    description = "ASCII art library for Python";
    homepage = "https://github.com/sepandhaghighi/art";
    changelog = "https://github.com/sepandhaghighi/art/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "art";
  };
}
