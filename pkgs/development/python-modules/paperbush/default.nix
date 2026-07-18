{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "paperbush";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "trag1c";
    repo = "paperbush";
    tag = finalAttrs.version;
    hash = "sha256-wJV+2aGK9eSw2iToiHh0I7vYAuND2pRYGhnf7CB1a+0=";
  };

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "paperbush" ];

  meta = {
    description = "Super concise argument parsing tool for Python";
    homepage = "https://github.com/trag1c/paperbush";
    changelog = "https://github.com/trag1c/paperbush/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
