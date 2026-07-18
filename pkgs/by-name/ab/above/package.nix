{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "above";
  version = "2.8.1";

  src = fetchFromGitHub {
    owner = "caster0x00";
    repo = "Above";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wyXWGfthzJeHZoJe4OKe9k2BIwLae/aOUtiJpT4SfHw=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    colorama
    scapy
  ];

  pyproject = true;

  meta = {
    description = "Invisible network protocol sniffer";
    homepage = "https://github.com/caster0x00/Above";
    changelog = "https://github.com/caster0x00/Above/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "above";
  };
})
