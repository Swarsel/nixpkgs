{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyserial,
  setuptools,
}:

buildPythonPackage rec {
  pname = "momonga";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "nbtk";
    repo = "momonga";
    tag = "v${version}";
    hash = "sha256-EJatEOpXJoRHEYs2ve90APOe17tBUZRWBygjIWWFW+c=";
  };

  # tests require access to the API
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pyserial
  ];

  pyproject = true;
  pythonImportsCheck = [ "momonga" ];

  meta = {
    description = "Python Route B Library: A Communicator for Low-voltage Smart Electric Energy Meters";
    homepage = "https://github.com/nbtk/momonga";
    changelog = "https://github.com/nbtk/momonga/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
