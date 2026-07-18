{
  lib,
  buildPythonPackage,
  gitpython,
  mypy,
  packaging,
  ruff,
  uv-build,
}:

buildPythonPackage {
  pname = "nixpkgs-plugin-update";
  version = "0.1.0";
  src = ./nixpkgs-plugin-update;

  nativeCheckInputs = [
    ruff
    mypy
  ];

  build-system = [ uv-build ];

  dependencies = [
    gitpython
    packaging
  ];

  postInstallCheck = ''
    ruff check
    mypy
  '';

  pyproject = true;
  # NOTE: Causes "Could not find a url in the derivations src attribute" crash in maintainer scripts
  passthru.updateScript = null;

  meta = {
    description = "Library for updating plugin collections in Nixpkgs";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      teto
      PerchunPak
      khaneliman
    ];
  };
}
