{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  prompt-toolkit,
  setuptools,
}:
buildPythonPackage rec {
  pname = "aiocmd";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "KimiNewt";
    repo = "aiocmd";
    tag = "v${version}";
    hash = "sha256-C8dpeMTaoOMgfNP19JUYKUf+Vyw36Ry6dHkhaSm/QNk=";
  };

  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ prompt-toolkit ];
  pyproject = true;
  pythonImportsCheck = [ "aiocmd" ];

  meta = {
    description = "Asyncio-based automatic CLI creation tool using prompt-toolkit";
    homepage = "https://github.com/KimiNewt/aiocmd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.znaniye ];
    platforms = lib.platforms.linux;
  };
}
