{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bravia-tv";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner = "dcnielsen90";
    repo = "python-bravia-tv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g47bDd5bZl0jad3o6T1jJLcnZj8nx944kz3Vxv8gD2U=";
  };

  # Package does not include tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "bravia_tv" ];

  meta = {
    description = "Python library for Sony Bravia TV remote control";
    homepage = "https://github.com/dcnielsen90/python-bravia-tv";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
