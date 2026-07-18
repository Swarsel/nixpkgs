{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  fuse3,
  pkg-config,
  pytest-trio,
  pytestCheckHook,
  python,
  setuptools,
  setuptools-scm,
  trio,
  which,
}:

buildPythonPackage rec {
  pname = "pyfuse3";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "libfuse";
    repo = "pyfuse3";
    tag = "v${version}";
    hash = "sha256-HhEtWYWdxJZOMS3dqB2VdQS7aSdpkRhq7EZCJ55n2OE=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ fuse3 ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-trio
    which
    fuse3
  ];

  build-system = [
    cython
    setuptools
    setuptools-scm
  ];

  dependencies = [ trio ];
  # Checks if a /usr/bin directory exists, can't work on NixOS
  disabledTests = [ "test_listdir" ];
  pyproject = true;

  pythonImportsCheck = [
    "pyfuse3"
    "pyfuse3.asyncio"
  ];

  meta = {
    description = "Python 3 bindings for libfuse 3 with async I/O support";
    homepage = "https://github.com/libfuse/pyfuse3";
    changelog = "https://github.com/libfuse/pyfuse3/blob/${src.tag}/Changes.rst";
    license = lib.licenses.lgpl2Plus;

    maintainers = with lib.maintainers; [
      nyanloutre
      dotlambda
    ];

    platforms = lib.platforms.linux;
  };
}
