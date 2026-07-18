{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  libstemmer,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pystemmer";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "snowballstem";
    repo = "pystemmer";
    tag = "v${version}";
    hash = "sha256-c3ucbneUo5UBfdrd5Ktl4HriVusvWBEA1brrgahEQ9A=";
  };

  env = {
    NIX_CFLAGS_COMPILE = toString [ "-I${lib.getDev libstemmer}/include" ];
    NIX_CFLAGS_LINK = toString [ "-L${libstemmer}/lib" ];
  };

  postConfigure = ''
    export PYSTEMMER_SYSTEM_LIBSTEMMER="${lib.getDev libstemmer}/include"
  '';

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} runtests.py
    runHook postCheck
  '';

  __structuredAttrs = true;

  build-system = [
    cython
    setuptools
  ];

  format = "setuptools";
  pyproejct = true;
  pythonImportsCheck = [ "Stemmer" ];

  meta = {
    description = "Snowball stemming algorithms, for information retrieval";
    homepage = "http://snowball.tartarus.org/";

    license = with lib.licenses; [
      bsd3
      mit
    ];

    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/snowballstem/pystemmer";
  };
}
