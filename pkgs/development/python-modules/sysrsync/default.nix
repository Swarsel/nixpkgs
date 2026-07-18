{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  rsync,
  setuptools,
  toml,
}:

buildPythonPackage rec {
  pname = "sysrsync";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "gchamon";
    repo = "sysrsync";
    tag = version;
    hash = "sha256-2Sz3JrNmIGOnad+qjRzbAgsFEzDtwBT0KLEFyQKZra4=";
  };

  postPatch = ''
    substituteInPlace sysrsync/command_maker.py \
      --replace-fail "'rsync'" "'${rsync}/bin/rsync'"
  '';

  build-system = [
    poetry-core
    setuptools
  ];

  dependencies = [
    toml
  ];

  pyproject = true;
  pythonImportsCheck = [ "sysrsync" ];

  meta = {
    description = "Simple and safe system's rsync wrapper for Python";
    homepage = "https://github.com/gchamon/sysrsync";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
