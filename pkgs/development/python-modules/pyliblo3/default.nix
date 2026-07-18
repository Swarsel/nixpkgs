{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  fetchpatch2,
  liblo,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyliblo3";
  version = "0.16.3";

  src = fetchFromGitHub {
    owner = "gesellkammer";
    repo = "pyliblo3";
    tag = "v${version}";
    hash = "sha256-QfwZXkUT4U2Gfbv3rk0F/bze9hwJGn7H8t0X1SWqIuc=";
  };

  patches = [
    # https://github.com/NixOS/nixpkgs/issues/437077
    (fetchpatch2 {
      hash = "sha256-fMKBVIZLBq62khhX40tpaM47nuHB0eqiURIul/4LMig=";
      name = "fix-compilation-for-cython-3.1.2";
      url = "https://github.com/gesellkammer/pyliblo3/commit/baa249acf91bcb851aa4e30e53e88728fe0fb0c9.patch?full_index=1";
    })
  ];

  buildInputs = [ liblo ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} ./test/unit.py
    runHook postCheck
  '';

  build-system = [
    setuptools
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyliblo3" ];

  meta = {
    description = "Python wrapper for the liblo OSC library";
    homepage = "https://github.com/gesellkammer/pyliblo3/";
    changelog = "https://github.com/gesellkammer/pyliblo3/blob/${src.tag}/NEWS";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.archercatneo ];
  };
}
