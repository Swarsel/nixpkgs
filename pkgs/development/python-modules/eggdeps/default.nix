{
  lib,
  buildPythonPackage,
  fetchPypi,
  zope-interface,
  zope-testing,
}:

buildPythonPackage rec {
  pname = "tl-eggdeps";
  version = "1.0";

  src = fetchPypi {
    inherit version;
    sha256 = "a094ed7961a3dd38fcaaa69cf7a58670038acdff186360166d9e3d964b7a7323";
    pname = "tl.eggdeps";
  };

  propagatedBuildInputs = [
    zope-interface
    zope-testing
  ];

  # tests fail, see https://hydra.nixos.org/build/4316603/log/raw
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Tool which computes a dependency graph between active Python eggs";
    homepage = "https://thomas-lotze.de/en/software/eggdeps/";
    license = lib.licenses.zpl20;
    mainProgram = "eggdeps";
  };
}
