{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyasyncore,
  setuptools,
}:

buildPythonPackage {
  pname = "pysecretsocks";
  version = "0.9.1-unstable-2023-11-04";

  src = fetchFromGitHub {
    owner = "BC-SECURITY";
    repo = "PySecretSOCKS";
    rev = "da5be0e48f82097044894247343cef2111f13c7a";
    hash = "sha256-3jvMVsoKgBN4eRc6hyj7X/uu7NoJvofsbljVcgGfcPc=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pyasyncore ];
  pyproject = true;
  pythonImportsCheck = [ "secretsocks" ];

  meta = {
    description = "Socks server for tunneling a connection over another channel";
    homepage = "https://github.com/BC-SECURITY/PySecretSOCKS";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
