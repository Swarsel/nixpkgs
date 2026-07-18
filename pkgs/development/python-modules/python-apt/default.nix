{
  lib,
  fetchFromGitLab,
  apt,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "apt";
  version = "3.1.0";

  src = fetchFromGitLab {
    owner = "apt-team";
    repo = "python-apt";
    tag = version;
    hash = "sha256-ISvPBBvo6PGYsGS/tKsBEOAEviuFRj5rgydJ5BQ1f+4=";
    domain = "salsa.debian.org";
  };

  buildInputs = [ apt.dev ];
  # Ensure the version is set properly without trying to invoke
  # dpkg-parsechangelog
  env.DEBVER = version;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "apt_pkg" ];

  meta = {
    description = "Python bindings for APT";
    homepage = "https://launchpad.net/python-apt";
    changelog = "https://salsa.debian.org/apt-team/python-apt/-/blob/${version}/debian/changelog";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      adhityaravi
      bepri
      dstathis
    ];

    platforms = lib.platforms.linux;
  };
}
