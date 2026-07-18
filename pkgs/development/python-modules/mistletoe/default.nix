{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  parameterized,
  pygments,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mistletoe";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "miyuchina";
    repo = "mistletoe";
    tag = "v${version}";
    hash = "sha256-h2gKvh3P4pUUPwVYTIjz43/3CwZdWbhO3aJnwFBNR+Q=";
  };

  nativeCheckInputs = [
    parameterized
    pygments
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "mistletoe" ];

  meta = {
    description = "Fast and extensible Markdown parser";
    homepage = "https://github.com/miyuchina/mistletoe";
    changelog = "https://github.com/miyuchina/mistletoe/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eadwu ];
    mainProgram = "mistletoe";
  };
}
