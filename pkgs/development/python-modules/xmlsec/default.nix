{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  hypothesis,
  # pkgconfig,
  # buildInputs
  libtool,
  libxml2,
  libxslt,
  # dependencies
  lxml,
  # nativeBuildInputs
  pkg-config,
  # build-system
  pkgconfig,
  pytestCheckHook,
  setuptools-scm,
  xmlsec,
}:

buildPythonPackage (finalAttrs: {
  pname = "xmlsec";
  version = "1.3.17";

  src = fetchFromGitHub {
    owner = "xmlsec";
    repo = "python-xmlsec";
    tag = finalAttrs.version;
    hash = "sha256-p3V75DLUI2PKdharP3/0HrKOgma9Kh3lAOZLRAQjo80=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "lxml==" "lxml>=" \
      --replace-fail "setuptools==" "setuptools>="
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libtool
    libxml2
    libxslt
    xmlsec
  ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [
    pkgconfig
    setuptools-scm
  ];

  dependencies = [ lxml ];

  disabledTestPaths = [
    # Full git clone required for test_doc_examples
    "tests/test_doc_examples.py"
  ];

  disabledTests = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
    # AssertionError: memory leak detected
    "test_reinitialize_module"
  ];

  pyproject = true;
  pythonImportsCheck = [ "xmlsec" ];

  meta = {
    description = "Python bindings for the XML Security Library";
    homepage = "https://github.com/xmlsec/python-xmlsec";
    changelog = "https://github.com/xmlsec/python-xmlsec/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zhaofengli ];
  };
})
