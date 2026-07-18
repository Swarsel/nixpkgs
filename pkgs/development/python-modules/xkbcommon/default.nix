{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
  libxkbcommon,
  pkg-config,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xkbcommon";
  version = "1.5.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-rBdICNv2HTXZ2oBL8zuqx0vG8r4MEIWUrpPHnNFd3DY=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libxkbcommon ];

  postBuild = ''
    ${python.pythonOnBuildForHost.interpreter} xkbcommon/ffi_build.py
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ cffi ];
  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "xkbcommon" ];

  meta = {
    description = "Python bindings for libxkbcommon using cffi";
    homepage = "https://github.com/sde1000/python-xkbcommon";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      chvp
      doronbehar
    ];
  };
})
