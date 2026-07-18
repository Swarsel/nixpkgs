{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hid-parser,
  libusb1,
  prompt-toolkit,
  pyserial,
  pythonAtLeast,
  pyusb,
  setuptools,
}:

buildPythonPackage rec {
  pname = "facedancer";
  version = "3.1.3";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "facedancer";
    tag = version;
    hash = "sha256-kWXO3q4KpMZNgZvVEw3yhKQ7eLzaVQ/4y+GQcd7Hd8U=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools-git-versioning<2"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    pyusb
    pyserial
    prompt-toolkit
    libusb1
    hid-parser
  ];

  pyproject = true;

  pythonImportsCheck = [
    "facedancer"
  ];

  meta = {
    description = "Implement your own USB device in Python, supported by a hardware peripheral such as Cynthion or GreatFET";
    homepage = "https://github.com/greatscottgadgets/facedancer";
    changelog = "https://github.com/greatscottgadgets/facedancer/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      mog
      carlossless
    ];

    # https://github.com/greatscottgadgets/facedancer/issues/172
    broken = pythonAtLeast "3.14";
  };
}
