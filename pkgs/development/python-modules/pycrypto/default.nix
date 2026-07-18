{ buildPythonPackage, pycryptodome }:

# This is a dummy package providing the drop-in replacement pycryptodome.
# https://github.com/NixOS/nixpkgs/issues/21671

buildPythonPackage rec {
  pname = "pycrypto";
  version = pycryptodome.version;
  propagatedBuildInputs = [ pycryptodome ];
  # Cannot build wheel otherwise (zip 1980 issue)
  env.SOURCE_DATE_EPOCH = 315532800;
  # Our dummy has no tests
  doCheck = false;
  format = "setuptools";

  # We need to have a dist-info folder, so let's create one with setuptools
  unpackPhase = ''
    echo "from setuptools import setup; setup(name='${pname}', version='${version}', install_requires=['pycryptodome'])" > setup.py
  '';

  meta = {
    description = "Drop-in replacement for pycrypto using pycryptodome";
    homepage = "https://www.pycrypto.org/";
    platforms = pycryptodome.meta.platforms;
  };
}
