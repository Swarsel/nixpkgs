{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  libgbinder,
  pkg-config,
  setuptools,
}:

buildPythonPackage rec {
  pname = "gbinder-python";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "waydroid";
    repo = "gbinder-python";
    tag = version;
    hash = "sha256-bXuvGTzYifiCPDkcNvkgh+RAZfckcyR8weaRkgbfCyA=";
  };

  postPatch = ''
    # Fix pkg-config name for cross-compilation
    substituteInPlace setup.py \
      --replace-fail "pkg-config" "$PKG_CONFIG"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ libgbinder ];

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Python bindings for libgbinder";
    homepage = "https://github.com/waydroid/gbinder-python";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
