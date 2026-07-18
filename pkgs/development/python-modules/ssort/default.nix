{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pathspec,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ssort";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "bwhmather";
    repo = "ssort";
    tag = version;
    hash = "sha256-QVodBJsYryVue0QXaZbjo1JtwuCBUiuZ+XU+I7jJCq8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  build-system = [ setuptools ];
  dependencies = [ pathspec ];
  pyproject = true;
  pythonImportsCheck = [ "ssort" ];

  meta = {
    description = "Automatically sorting python statements within a module";
    homepage = "https://github.com/bwhmather/ssort";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tochiaha ];
    mainProgram = "ssort";
  };
}
