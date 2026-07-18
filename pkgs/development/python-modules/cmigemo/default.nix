{
  lib,
  stdenv,
  buildPythonPackage,
  cmigemo,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "cmigemo";
  version = "0.1.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-cxOqMAf2dgCwZuBKSAXkRFY9FRNB3rMwE1tNzfZERiY=";
  };

  postPatch = ''
    sed -i 's~dict_path_base = "/usr/share/cmigemo"~dict_path_base = "/${cmigemo}/share/migemo"~g' test/test_cmigemo.py
  '';

  preConfigure = ''
    export LDFLAGS="-L${cmigemo}/lib"
    export CPPFLAGS="-I${cmigemo}/include"
    export LD_LIBRARY_PATH="${cmigemo}/lib"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ six ];
  enabledTestPaths = [ "test/" ];
  pyproject = true;
  pythonImportsCheck = [ "cmigemo" ];

  meta = {
    description = "Pure python binding for C/Migemo";
    homepage = "https://github.com/mooz/python-cmigemo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ illustris ];
    broken = stdenv.hostPlatform.isDarwin;
  };
})
