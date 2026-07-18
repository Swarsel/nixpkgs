{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  luna-usb,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "luna-soc";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "luna-soc";
    tag = version;
    hash = "sha256-Rks1wC0CR5FSu4TrE1thzolT3QBd0yh7q+SxZ1U+pB4=";
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

  dependencies = [ luna-usb ];
  pyproject = true;

  pythonImportsCheck = [
    "luna_soc"
  ];

  meta = {
    description = "Amaranth HDL library for building USB-capable SoC designs";
    homepage = "https://github.com/greatscottgadgets/luna-soc";
    changelog = "https://github.com/greatscottgadgets/luna-soc/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ carlossless ];
  };
}
