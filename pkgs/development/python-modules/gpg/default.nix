{
  lib,
  fetchurl,
  autoreconfHook,
  buildPythonPackage,
  gnupg,
  gpgme,
  libgpg-error,
  setuptools,
  swig,
}:

buildPythonPackage rec {
  pname = "gpg";
  version = "2.0.0";

  src = fetchurl {
    url = "mirror://gnupg/gpgmepy/gpgmepy-${version}.tar.bz2";
    hash = "sha256-B+EmVkj/UdojjJr3oYs/HcewxmtPIacvJ8dLOWzTM20=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "swig"' ""

    # prevent `packaging.version.InvalidVersion: Invalid version: '2.0.0-unknown'`
    substituteInPlace autogen.sh \
      --replace-fail 'tmp="-unknown"' 'tmp=""'
  '';

  nativeBuildInputs = [
    autoreconfHook
    gpgme # for gpgme-config
    libgpg-error # for gpg-error-config
    swig
  ];

  buildInputs = [
    gpgme
    libgpg-error
  ];

  preBuild = ''
    # prevent `error: package directory 'gpg' does not exist`
    mv src gpg
  '';

  nativeCheckInputs = [
    gnupg
  ];

  checkPhase = ''
    runHook preCheck

    make -C tests

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "gpg" ];

  meta = {
    description = "Python bindings to the GPGME API of the GnuPG cryptography library";
    homepage = "https://dev.gnupg.org/source/gpgmepy/";
    changelog = "https://dev.gnupg.org/source/gpgmepy/browse/master/NEWS;gpgmepy-${version}?as=remarkup";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
