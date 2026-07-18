{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  grpcio,
  hatch-vcs,
  hatchling,
  protobuf,
}:

buildPythonPackage rec {
  pname = "ghome-foyer-api";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = "ghome-foyer-api";
    tag = "v${version}";
    hash = "sha256-hIprnkfAUbKoAp++sxu+T7MuGqLKOM1N1hqGBDOSo3k=";
  };

  buildInputs = [
    hatchling
    hatch-vcs
  ];

  doCheck = false; # no tests

  dependencies = [
    grpcio
    protobuf
  ];

  pyproject = true;
  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Generated Python protobuf stubs for Google Home internal API";
    homepage = "https://github.com/KapJI/ghome-foyer-api";
    changelog = "https://github.com/KapJI/ghome-foyer-api/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      hensoko
    ];
  };
}
