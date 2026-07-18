{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyroute2";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "svinota";
    repo = "pyroute2";
    tag = finalAttrs.version;
    hash = "sha256-ZseZQFiR+btDsR+ozcd8DBp0vsNTb6tIzaArQfOk7CI=";
  };

  postPatch = ''
    patchShebangs util
    make VERSION
  '';

  # Requires root privileges, https://github.com/svinota/pyroute2/issues/778
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "pyroute2"
    "pyroute2.common"
    "pyroute2.config"
    "pyroute2.ethtool"
    "pyroute2.ipdb"
    "pyroute2.ipset"
    "pyroute2.ndb"
    "pyroute2.nftables"
    "pyroute2.nslink"
    "pyroute2.protocols"
  ];

  meta = {
    description = "Python Netlink library";
    homepage = "https://github.com/svinota/pyroute2";
    changelog = "https://github.com/svinota/pyroute2/blob/${finalAttrs.src.tag}/CHANGELOG.rst";

    license = with lib.licenses; [
      asl20 # or
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [
      fab
      mic92
    ];

    platforms = lib.platforms.unix;
  };
})
