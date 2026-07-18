{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyserial,
  setuptools,
}:

buildPythonPackage rec {
  pname = "asyncserial";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "m-labs";
    repo = "asyncserial";
    tag = version;
    hash = "sha256-ZHzgJnbsDVxVcp09LXq9JZp46+dorgdP8bAiTB59K28=";
  };

  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  pyproject = true;
  pythonImportsCheck = [ "asyncserial" ];

  meta = {
    description = "asyncio support for pyserial";
    homepage = "https://github.com/m-labs/asyncserial";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
