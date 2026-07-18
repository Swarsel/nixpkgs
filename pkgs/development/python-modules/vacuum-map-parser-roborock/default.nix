{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  poetry-core,
  vacuum-map-parser-base,
}:

buildPythonPackage rec {
  pname = "vacuum-map-parser-roborock";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "PiotrMachowski";
    repo = "Python-package-${pname}";
    tag = "v${version}";
    hash = "sha256-v9T9KGKi2vvxZQDjL6CBziPisgQ7sp3HnWZgZ/e8kVY=";
  };

  postPatch = ''
    # Upstream doesn't set a version in the pyproject.toml file
    substituteInPlace pyproject.toml \
      --replace "0.0.0" "${version}"
  '';

  # No tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    pillow
    vacuum-map-parser-base
  ];

  pyproject = true;
  pythonImportsCheck = [ "vacuum_map_parser_roborock" ];

  meta = {
    description = "Functionalities for Roborock vacuum map parsing";
    homepage = "https://github.com/PiotrMachowski/Python-package-vacuum-map-parser-roborock";
    changelog = "https://github.com/PiotrMachowski/Python-package-vacuum-map-parser-roborock/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
