{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  libnl,
  net-tools,
  pkg-config,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ethtool";
  version = "0.15";

  src = fetchFromGitHub {
    owner = "fedora-python";
    repo = "python-ethtool";
    tag = "v${version}";
    hash = "sha256-0XzGaqpkEv3mpUsbfOtRl8E62iNdS7kRoo4oYrBjMys=";
  };

  patches = [
    # https://github.com/fedora-python/python-ethtool/pull/60
    (fetchpatch2 {
      hash = "sha256-mtI7XsoyM43s2DFQdsBNpB8jJff7ZyO2J6SHodBrdrI=";
      url = "https://github.com/fedora-python/python-ethtool/commit/f82dd763bd50affda993b9afe3b141069a1a7466.patch";
    })
  ];

  postPatch = ''
    substituteInPlace tests/parse_ifconfig.py \
      --replace-fail "Popen('ifconfig'," "Popen('${lib.getExe' net-tools "ifconfig"}',"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libnl ];

  nativeCheckInputs = [
    net-tools
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ethtool" ];

  meta = {
    description = "Python bindings for the ethtool kernel interface";
    homepage = "https://github.com/fedora-python/python-ethtool";
    changelog = "https://github.com/fedora-python/python-ethtool/blob/${src.rev}/CHANGES.rst";
    license = lib.licenses.gpl2Plus;
  };
}
