{
  lib,
  buildPythonPackage,
  fetchPypi,
  rizin,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rzpipe";
  version = "0.6.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-KKqPFMGgsmiYZ0tXTIhhvhLDfm/iV8JcYeVc4akezYc=";
  };

  postPatch = ''
    substituteInPlace rzpipe/open_sync.py \
      --replace-fail "cmd = [rze," "cmd = ['${lib.getExe rizin}',"
  '';

  # No native rz_core library
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "rzpipe" ];

  meta = {
    description = "Python interface for rizin";
    homepage = "https://rizin.re";
    changelog = "https://github.com/rizinorg/rizin/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
