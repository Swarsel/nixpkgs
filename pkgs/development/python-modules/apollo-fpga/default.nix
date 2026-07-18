{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  deprecation,
  prompt-toolkit,
  pyusb,
  pyvcd,
  pyxdg,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "apollo-fpga";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "apollo";
    tag = "v${version}";
    hash = "sha256-EDI+bRDePEbkxfQKuDgRsJtlAE0jqcIoQHjpgW0jIoY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools-git-versioning<2"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  # has no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    deprecation
    prompt-toolkit
    pyusb
    pyvcd
    pyxdg
  ];

  pyproject = true;

  pythonImportsCheck = [
    "apollo_fpga"
  ];

  meta = {
    description = "Microcontroller-based FPGA / JTAG programmer";
    homepage = "https://github.com/greatscottgadgets/apollo";
    changelog = "https://github.com/greatscottgadgets/apollo/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ carlossless ];
  };
}
