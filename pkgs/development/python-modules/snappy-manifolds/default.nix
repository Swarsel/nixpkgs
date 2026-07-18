{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  setuptools,
}:

buildPythonPackage rec {
  pname = "snappy-manifolds";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "3-manifolds";
    repo = "snappy_manifolds";
    tag = "${version}_as_released";
    hash = "sha256-e+BoPvg0cuEqLq2f9ZPgqFMEYw7eeSEDkY42+l+kDCk=";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "snappy_manifolds" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "(.*)_as_released"
    ];
  };

  meta = {
    description = "Database of snappy manifolds";
    homepage = "https://snappy.computop.org";
    changelog = "https://github.com/3-manifolds/snappy_manifolds/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      noiioiu
      alejo7797
    ];
  };
}
