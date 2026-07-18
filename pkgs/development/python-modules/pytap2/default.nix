{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  net-tools,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytap2";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "johnthagen";
    repo = "pytap2";
    rev = "v${version}";
    hash = "sha256-GN8yFnS7HVgIP73/nVtYnwwhCBI9doGHLGSOaFiWIdw=";
  };

  propagatedBuildInputs = [ net-tools ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "pytap2" ];

  meta = {
    description = "Object-oriented wrapper around the Linux Tun/Tap device";
    homepage = "https://github.com/johnthagen/pytap2";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.linux;
  };
}
