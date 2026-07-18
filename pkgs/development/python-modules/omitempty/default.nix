{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "omitempty";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "bfontaine";
    repo = "omitempty";
    tag = finalAttrs.version;
    hash = "sha256-XQ887ArfxXnPJcCksgS5Zkg9VAfGRxu0wapewsnqdpY=";
  };

  # Tests are outdated
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "omitempty" ];

  meta = {
    description = "Go's omitempty for Python";
    homepage = "https://github.com/bfontaine/omitempty";
    changelog = "https://github.com/bfontaine/omitempty/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
