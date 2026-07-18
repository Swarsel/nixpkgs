{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "unidecode";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "avian2";
    repo = "unidecode";
    tag = "unidecode-${version}";
    hash = "sha256-CPogyDw8B1Xd3Bt6W9OaImVt+hFQsir16mnSYk8hFWQ=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "unidecode" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "unidecode-(.*)"
    ];
  };

  meta = {
    description = "ASCII transliterations of Unicode text";
    homepage = "https://github.com/avian2/unidecode";
    changelog = "https://github.com/avian2/unidecode/blob/unidecode-${version}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "unidecode";
  };
}
