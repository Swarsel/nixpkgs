{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pillow,
  setuptools,
}:

buildPythonPackage rec {
  pname = "haishoku";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "LanceGin";
    repo = "haishoku";
    tag = "v${version}";
    hash = "sha256-LSoZopCaM5vbknGS9gG13OZIgghgqJvPtktUkBCH04Q=";
  };

  # no test
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pillow ];
  pyproject = true;
  pythonImportsCheck = [ "haishoku" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Development tool for grabbing the dominant color or representative color palette from an image";
    homepage = "https://github.com/LanceGin/haishoku";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
