{
  lib,
  aenum,
  buildPythonPackage,
  dacite,
  home-assistant-chip-wheels,
}:

buildPythonPackage rec {
  inherit (home-assistant-chip-wheels) version;
  pname = "home-assistant-chip-clusters";
  src = home-assistant-chip-wheels;

  propagatedBuildInputs = [
    aenum
    dacite
  ];

  doCheck = false; # no tests
  format = "wheel";

  # format=wheel needs src to be a wheel not a folder of wheels
  preUnpack = ''
    src=($src/home_assistant_chip_clusters*.whl)
  '';

  pythonImportsCheck = [
    "chip.clusters"
    "chip.clusters.ClusterObjects"
    "chip.tlv"
  ];

  meta = {
    description = "Python-base APIs and tools for CHIP";
    homepage = "https://github.com/home-assistant-libs/chip-wheels";
    changelog = "https://github.com/home-assistant-libs/chip-wheels/releases/tag/${version}";
    license = lib.licenses.asl20;
    teams = [ lib.teams.home-assistant ];
  };
}
