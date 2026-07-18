{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "binary";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "ofek";
    repo = "binary";
    tag = "v${version}";
    hash = "sha256-dU+E6MxAmH8AEGTW2/lZmtgRTinKCv9gDiVeb4n78U4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;

  pythonImportsCheck = [
    "binary"
    "binary.core"
  ];

  meta = {
    description = "Easily convert between binary and SI units (kibibyte, kilobyte, etc.)";
    homepage = "https://github.com/ofek/binary";
    changelog = "https://github.com/ofek/binary/releases/tag/${src.tag}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = [ ];
  };
}
