{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "x11-hash";
  version = "1.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-QtzqxEzpVGK48/lvOEr8VtPUYexLdXKD3zGv1VOdWpw=";
    pname = "x11_hash";
  };

  nativeBuildInputs = [ setuptools ];
  # pypi's source doesn't include tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "x11_hash" ];

  meta = {
    description = "Binding for X11 proof of work hashing";
    homepage = "https://github.com/mazaclub/x11_hash";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ np ];
  };
}
