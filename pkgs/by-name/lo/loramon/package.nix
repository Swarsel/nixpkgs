{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "loramon";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "markqvist";
    repo = "LoRaMon";
    tag = finalAttrs.version;
    hash = "sha256-94tXhuAoaS1y/zGz63PPqOayRylGK0Ei2a6H4/BCB30";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pyserial
  ];

  pyproject = true;

  meta = {
    description = "LoRa packet sniffer for RNode hardware";
    homepage = "https://github.com/markqvist/LoRaMon";
    changelog = "https://github.com/markqvist/LoRaMon/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erethon ];
    mainProgram = "loramon";
  };
})
