{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "sre-yield";
  version = "1.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-6U8aKjy6//4dzRXB1U5AGhUX4FKqZMfTFk+I3HYde4o=";
    pname = "sre_yield";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Python library to efficiently generate all values that can match a given regular expression";
    homepage = "https://github.com/sre-yield/sre-yield";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ danc86 ];
    mainProgram = "demo_sre_yield";
  };
})
