{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "sewer";
  version = "0.8.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "sha256-a4VdbZY8pYxrXIaUHJpnLuTB928tJn4UCdnt+m8UBug=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyopenssl
    requests
    tldextract
  ];

  pyproject = true;
  pythonImportsCheck = [ "sewer" ];

  meta = {
    description = "ACME client";
    homepage = "https://github.com/komuw/sewer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kevincox ];
  };
})
