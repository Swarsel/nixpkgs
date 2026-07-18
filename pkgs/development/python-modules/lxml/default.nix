{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # native dependencies
  libxml2,
  libxslt,
  pkg-config,
  setuptools,
  xcodebuild,
  zlib,
}:

buildPythonPackage (finalAttrs: {
  pname = "lxml";
  version = "6.1.1";

  src = fetchFromGitHub {
    owner = "lxml";
    repo = "lxml";
    tag = "lxml-${finalAttrs.version}";
    hash = "sha256-SRJaegK4PxgK0rdILVp3J92VnjPmExiD2AuMLoGQIbA=";
  };

  # required for build time dependency check
  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxml2
    libxslt
    zlib
  ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-function-pointer-types";
  };

  # tests are meant to be ran "in-place" in the same directory as src
  doCheck = false;

  build-system = [
    cython
    setuptools
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcodebuild ];

  pyproject = true;

  pythonImportsCheck = [
    "lxml"
    "lxml.etree"
  ];

  meta = {
    description = "Pythonic binding for the libxml2 and libxslt libraries";
    homepage = "https://lxml.de";
    changelog = "https://github.com/lxml/lxml/blob/${finalAttrs.src.tag}/CHANGES.txt";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
