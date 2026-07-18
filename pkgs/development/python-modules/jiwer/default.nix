{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  hatchling,
  rapidfuzz,
}:

buildPythonPackage rec {
  pname = "jiwer";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "jitsi";
    repo = "jiwer";
    tag = "v${version}";
    hash = "sha256-iyFcxZGYMeQXSZBHJg7kBWyOciZyEV7gSzSy4SvBGzw=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    rapidfuzz
    click
  ];

  pyproject = true;
  pythonImportsCheck = [ "jiwer" ];
  pythonRelaxDeps = [ "rapidfuzz" ];

  meta = {
    description = "Simple and fast python package to evaluate an automatic speech recognition system";
    homepage = "https://github.com/jitsi/jiwer";
    changelog = "https://github.com/jitsi/jiwer/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "jiwer";
  };
}
