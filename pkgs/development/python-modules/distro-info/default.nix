{
  lib,
  fetchurl,
  buildPythonPackage,
  distro-info-data,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "distro-info";
  version = "1.14";

  # Not using fetchFromGitLab because it incorrectly sets
  # SOURCE_DATE_EPOCH=315619200 (1980-01-02) and breaks tests.
  src = fetchurl {
    url = "https://salsa.debian.org/debian/distro-info/-/archive/debian/${version}/distro-info-debian-${version}.tar.gz";
    hash = "sha256-nRLTlDPnll1jvwfg9FSxs9TmImvQkn9DVqSRSOKTAGI=";
  };

  postPatch = ''
    substituteInPlace python/distro_info.py \
      --replace-fail /usr/share/distro-info ${distro-info-data}/share/distro-info
  '';

  nativeCheckInputs = [
    unittestCheckHook
  ];

  preCheck = ''
    cd python
    rm distro_info_test/test_flake8.py distro_info_test/test_pylint.py
  '';

  build-system = [ setuptools ];
  pypaBuildFlags = "python";
  pyproject = true;

  meta = {
    description = "Information about Debian and Ubuntu releases";
    homepage = "https://salsa.debian.org/debian/distro-info";
    changelog = "https://salsa.debian.org/debian/distro-info/-/blob/debian/${version}/debian/changelog";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ andersk ];
    platforms = lib.platforms.all;
  };
}
