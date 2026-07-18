{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  supervise,
}:

buildPythonPackage rec {
  pname = "supervise-api";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-EjD0IpSRDoNCG307CKlo0n1RCkpwnpZlB+1w212hud4=";
    pname = "supervise_api";
  };

  postPatch = ''
    substituteInPlace supervise_api/supervise.py \
      --replace 'which("supervise")' '"${supervise}/bin/supervise"'
  '';

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "supervise_api" ];

  meta = {
    description = "API for running processes safely and securely";
    homepage = "https://github.com/catern/supervise";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
