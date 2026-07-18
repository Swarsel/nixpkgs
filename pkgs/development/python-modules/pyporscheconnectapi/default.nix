{
  lib,
  fetchFromGitHub,
  aiofiles,
  beautifulsoup4,
  buildPythonPackage,
  httpx,
  rich,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyporscheconnectapi";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "CJNE";
    repo = "pyporscheconnectapi";
    tag = finalAttrs.version;
    hash = "sha256-c46XAWKf7LeQ9Nz1IumOIs/Z8DuCa2zaatBizFT+FMg=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"pytest-runner"' ""
  '';

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    beautifulsoup4
    httpx
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyporscheconnectapi" ];

  meta = {
    description = "Python client library for Porsche Connect API";
    homepage = "https://github.com/CJNE/pyporscheconnectapi";
    changelog = "https://github.com/CJNE/pyporscheconnectapi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
