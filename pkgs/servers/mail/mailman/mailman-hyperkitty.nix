{
  lib,
  fetchPypi,
  mailman,
  nixosTests,
  python3,
}:

with python3.pkgs;
buildPythonPackage (finalAttrs: {
  pname = "mailman-hyperkitty";
  version = "1.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-+Nad+8bMtYKJbUCpppRXqhB1zdbvvFXTTHlwJLQLzDg=";
  };

  propagatedBuildInputs = [
    mailman
    requests
    zope-interface
  ];

  # There is an AssertionError
  doCheck = false;

  nativeCheckInputs = [
    mock
    nose2
  ];

  checkPhase = ''
    ${python.interpreter} -m nose2 -v
  '';

  format = "setuptools";

  pythonImportsCheck = [
    "mailman_hyperkitty"
  ];

  passthru.tests = { inherit (nixosTests) mailman; };

  meta = {
    description = "Mailman archiver plugin for HyperKitty";
    homepage = "https://gitlab.com/mailman/mailman-hyperkitty";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ qyliss ];
  };
})
