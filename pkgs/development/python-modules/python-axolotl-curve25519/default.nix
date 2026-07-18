{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-axolotl-curve25519";
  version = "0.4.1.post2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0705a66297ebd2f508a60dc94e22881c754301eb81db93963322f6b3bdcb63a3";
  };

  patches = [
    # https://github.com/tgalal/python-axolotl-curve25519/pull/26
    (fetchpatch {
      hash = "sha256-hdhaOysRXI9q5D9e/bfy0887bpEFSvUyrbl32nBgteQ=";
      url = "https://github.com/tgalal/python-axolotl-curve25519/commit/901f4fb12e1290b72fbd26ea1f40755b079fa241.patch";
    })
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Curve25519 with ed25519 signatures";
    homepage = "https://github.com/tgalal/python-axolotl-curve25519";
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
}
