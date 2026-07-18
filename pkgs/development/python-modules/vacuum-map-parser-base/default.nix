{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "vacuum-map-parser-base";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "PiotrMachowski";
    repo = "Python-package-${pname}";
    tag = "v${version}";
    hash = "sha256-jB3/m2qlaDnc9fVTlM0wR2ROZmJQ1h6a+awauOa312g=";
  };

  postPatch = ''
    # Upstream doesn't set a version in the pyproject.toml file
    substituteInPlace pyproject.toml \
      --replace "0.0.0" "${version}"
  '';

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ pillow ];
  # No tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "vacuum_map_parser_base" ];

  meta = {
    description = "Common code for vacuum map parsers";
    homepage = "https://github.com/PiotrMachowski/Python-package-vacuum-map-parser-base";
    changelog = "https://github.com/PiotrMachowski/Python-package-vacuum-map-parser-base/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
