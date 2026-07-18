{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  glibcLocales,
  pycodestyle,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "autopep8";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "hhatto";
    repo = "autopep8";
    tag = "v${version}";
    hash = "sha256-9OJ5XbzpHMHsFjf5oVyHjn5zqmAxRuSItWP4sQx8jD4=";
  };

  propagatedBuildInputs = [ pycodestyle ];
  env.LC_ALL = "en_US.UTF-8";

  nativeCheckInputs = [
    glibcLocales
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Tool that automatically formats Python code to conform to the PEP 8 style guide";
    homepage = "https://github.com/hhatto/autopep8";
    changelog = "https://github.com/hhatto/autopep8/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bjornfor ];
    mainProgram = "autopep8";
  };
}
