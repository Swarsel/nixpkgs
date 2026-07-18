{
  lib,
  buildPythonPackage,
  coloredlogs,
  construct,
  cryptography,
  dacite,
  deprecation,
  home-assistant-chip-wheels,
  ipdb,
  pyyaml,
  rich,
}:

buildPythonPackage rec {
  inherit (home-assistant-chip-wheels) version;
  pname = "home-assistant-chip-core";
  src = home-assistant-chip-wheels;
  doCheck = false; # no tests

  dependencies = [
    coloredlogs
    construct
    cryptography
    dacite
    rich
    pyyaml
    ipdb
    deprecation
  ];

  format = "wheel";

  # format=wheel needs src to be a wheel not a folder of wheels
  preUnpack = ''
    src=($src/home_assistant_chip_core*.whl)
  '';

  pythonImportsCheck = [
    "chip"
    "chip.ble"
    "chip.configuration"
    "chip.discovery"
    "chip.exceptions"
    "chip.native"
    "chip.storage"
  ];

  pythonNamespaces = [
    "chip"
    "chip.clusters"
  ];

  # only used for testing purposes, unsafe to use in production
  pythonRemoveDeps = [ "ecdsa" ];

  meta = {
    description = "Python-base APIs and tools for CHIP";
    homepage = "https://github.com/home-assistant-libs/chip-wheels";
    changelog = "https://github.com/home-assistant-libs/chip-wheels/releases/tag/${version}";
    license = lib.licenses.asl20;
    teams = [ lib.teams.home-assistant ];
  };
}
