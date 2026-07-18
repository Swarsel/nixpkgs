{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest7CheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pymeeus";
  version = "0.5.12";

  src = fetchPypi {
    inherit version;
    hash = "sha256-VI9xhr2LlsvAac9kmo6ON33OSax0SGcJhJ/mOpnK1oQ=";
    pname = "PyMeeus";
  };

  nativeCheckInputs = [ pytest7CheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Library of astronomical algorithms";
    homepage = "https://github.com/architest/pymeeus";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
