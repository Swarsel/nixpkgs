{
  lib,
  buildPythonPackage,
  fetchPypi,
  types-futures,
}:

buildPythonPackage rec {
  pname = "types-protobuf";
  version = "6.32.1.20260221";

  src = fetchPypi {
    inherit version;
    hash = "sha256-bV+wYKYWv7B2y7YbSzw5afX8i+xYEPmi9+ZI7ly8v24=";
    pname = "types_protobuf";
  };

  propagatedBuildInputs = [ types-futures ];
  # Module doesn't have tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "google-stubs" ];

  meta = {
    description = "Typing stubs for protobuf";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ andersk ];
  };
}
