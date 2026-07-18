{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  cython,
  fetchzip,
  numpy,
  oldest-supported-numpy,
  python,
  setuptools,
  setuptools-scm,
  tqdm,
}:

let
  dic-dirname = "open_jtalk_dic_utf_8-1.11";
  dic-src = fetchzip {
    hash = "sha256-+6cHKujNEzmJbpN9Uan6kZKsPdwxRRzT3ZazDnCNi3s=";
    url = "https://github.com/r9y9/open_jtalk/releases/download/v1.11.1/${dic-dirname}.tar.gz";
  };
in
buildPythonPackage {
  pname = "pyopenjtalk";
  version = "0-unstable-2025-04-23";

  src = fetchFromGitHub {
    owner = "VOICEVOX";
    repo = "pyopenjtalk";
    rev = "74703b034dd90a1f199f49bb70bf3b66b1728a86";
    hash = "sha256-UUUYoVEqENKux5N7ucbjcnrZ2+ewwxwP8S0WksaJEAQ=";
    fetchSubmodules = true;
  };

  # needed because setuptools-scm doesn't like the 0-unstable format
  env.SETUPTOOLS_SCM_PRETEND_VERSION = "0.0.1";

  postInstall = ''
    ln -s ${dic-src} $out/${python.sitePackages}/pyopenjtalk/${dic-dirname}
  '';

  build-system = [
    setuptools
    setuptools-scm
    cython
    cmake
    numpy
    oldest-supported-numpy
  ];

  dependencies = [
    numpy
    tqdm
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  meta = {
    description = "VOICEVOX's fork of the pyopenjtalk text-to-speech library";
    homepage = "https://github.com/VOICEVOX/pyopenjtalk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
}
