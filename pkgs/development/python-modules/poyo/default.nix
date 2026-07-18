{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "poyo";
  version = "0.5.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "1pflivs6j22frz0v3dqxnvc8yb8fb52g11lqr88z0i8cg2m5csg2";
  };

  format = "setuptools";

  meta = {
    description = "Lightweight YAML Parser for Python";
    homepage = "https://github.com/hackebrot/poyo";
    license = lib.licenses.mit;
  };
})
