{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  typeguard,
  wheel,
}:

buildPythonPackage rec {
  pname = "scheduler";
  version = "0.8.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RXWhLNJp5OSJZAmDb9kRVgy2P7djQ2DuYqovpOxJX/0=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    typeguard
  ];

  pyproject = true;
  pythonImportsCheck = [ "scheduler" ];

  meta = {
    description = "Simple in-process python scheduler library with asyncio, threading and timezone support";
    homepage = "https://pypi.org/project/scheduler/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ pinpox ];
  };
}
