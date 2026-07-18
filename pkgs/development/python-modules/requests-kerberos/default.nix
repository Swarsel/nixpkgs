{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pyspnego,
  pytest-mock,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "requests-kerberos";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "requests";
    repo = "requests-kerberos";
    rev = "v${version}";
    hash = "sha256-s1Q3zqKPSuTkiFExr+axai9Eta1xjw/cip8xzfDGR88=";
  };

  propagatedBuildInputs = [
    cryptography
    requests
    pyspnego
  ]
  # Avoid broken Python krb5 package on Darwin
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) pyspnego.optional-dependencies.kerberos;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  format = "setuptools";
  pythonImportsCheck = [ "requests_kerberos" ];

  meta = {
    description = "Authentication handler for using Kerberos with Python Requests";
    homepage = "https://github.com/requests/requests-kerberos";
    license = lib.licenses.isc;
  };
}
