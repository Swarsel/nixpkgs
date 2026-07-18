{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "protego";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "scrapy";
    repo = "protego";
    tag = finalAttrs.version;
    hash = "sha256-vAX7l0Xq2itQwBkNYobOWae1qHVVcD7M/o43GpIwEVo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "protego" ];

  meta = {
    description = "Module to parse robots.txt files with support for modern conventions";
    homepage = "https://github.com/scrapy/protego";
    changelog = "https://github.com/scrapy/protego/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
