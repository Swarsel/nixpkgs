{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycayennelpp";
  version = "2.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1cc6lz28aa57gs74767xyd3i370lwx046yb5a1nfch6fk3kf7xdx";
  };

  # Patch setup.py to remove pytest-runner
  postPatch = ''
    substituteInPlace setup.py \
      --replace '"pytest-runner"' ""
  '';

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Python library for Cayenne Low Power Payload";
    homepage = "https://github.com/smlng/pycayennelpp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.haylin ];
  };
}
