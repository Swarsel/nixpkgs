{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pynintendoauth,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pynintendoparental";
  version = "2.4.0.1";

  src = fetchFromGitHub {
    owner = "pantherale0";
    repo = "pynintendoparental";
    tag = finalAttrs.version;
    hash = "sha256-1ZL6vDFCLzduj4fcgg9kEhogoD44eURd2nvOc0A5ghM=";
  };

  postPatch = ''
    substituteInPlace pynintendoparental/_version.py \
      --replace-fail '__version__ = "0.0.0"' '__version__ = "${finalAttrs.version}"'
  '';

  # test.py connects to the actual API
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pynintendoauth
  ];

  pyproject = true;
  pythonImportsCheck = [ "pynintendoparental" ];

  meta = {
    description = "Python module to interact with Nintendo Parental Controls";
    homepage = "https://github.com/pantherale0/pynintendoparental";
    changelog = "https://github.com/pantherale0/pynintendoparental/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
