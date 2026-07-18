{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "crossplane";
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "nginxinc";
    repo = "crossplane";
    tag = "v${version}";
    hash = "sha256-DfIF+JvjIREi7zd5ZQ7Co/CIKC5iUeOgR/VLDPmrtTQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "crossplane" ];

  meta = {
    description = "NGINX configuration file parser and builder";
    homepage = "https://github.com/nginxinc/crossplane";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kaction ];
    mainProgram = "crossplane";
  };
}
