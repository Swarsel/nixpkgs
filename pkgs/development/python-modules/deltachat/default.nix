{
  buildPythonPackage,
  cffi,
  imap-tools,
  libdeltachat,
  pkg-config,
  pkgconfig,
  pluggy,
  pytestCheckHook,
  requests,
  setuptools-scm,
}:

buildPythonPackage rec {
  inherit (libdeltachat) version src;
  pname = "deltachat";

  nativeBuildInputs = [
    cffi
    pkg-config
    pkgconfig
    setuptools-scm
  ];

  buildInputs = [ libdeltachat ];

  propagatedBuildInputs = [
    cffi
    imap-tools
    pluggy
    requests
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  pythonImportsCheck = [
    "deltachat"
    "deltachat.account"
    "deltachat.contact"
    "deltachat.chat"
    "deltachat.message"
  ];

  sourceRoot = "${src.name}/python";

  meta = libdeltachat.meta // {
    description = "Python bindings for the Delta Chat Core library";
    homepage = "https://github.com/deltachat/deltachat-core-rust/tree/master/python";
  };
}
