{
  lib,
  buildPythonPackage,
  fetchgit,
  pycrypto,
  pyptlib,
  pyyaml,
  twisted,
}:

buildPythonPackage rec {
  pname = "obfsproxy";
  version = "0.2.13";

  src = fetchgit {
    url = "https://git.torproject.org/pluggable-transports/obfsproxy.git";
    tag = "${pname}-${version}";
    sha256 = "04ja1cl8xzqnwrd2gi6nlnxbmjri141bzwa5gybvr44d8h3k2nfa";
  };

  postPatch = ''
    substituteInPlace setup.py --replace "version=versioneer.get_version()" "version='${version}'"
    substituteInPlace setup.py --replace "argparse" ""
  '';

  propagatedBuildInputs = [
    pyptlib
    twisted
    pycrypto
    pyyaml
  ];

  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Pluggable transport proxy";
    homepage = "https://www.torproject.org/projects/obfsproxy";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ thoughtpolice ];
  };
}
