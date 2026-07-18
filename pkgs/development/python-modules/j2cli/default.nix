{
  lib,
  buildPythonPackage,
  fetchPypi,
  jinja2,
  pythonAtLeast,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "j2cli";
  version = "0.3.10";

  src = fetchPypi {
    inherit pname version;
    sha256 = "6f6f643b3fa5c0f72fbe9f07e246f8e138052b9f689e14c7c64d582c59709ae4";
  };

  propagatedBuildInputs = [
    jinja2
    pyyaml
    setuptools
  ];

  doCheck = false; # tests aren't installed thus aren't found, so skip
  disabled = pythonAtLeast "3.12";
  format = "setuptools";

  meta = {
    description = "Jinja2 Command-Line Tool";

    longDescription = ''
      J2Cli is a command-line tool for templating in shell-scripts,
      leveraging the Jinja2 library.
    '';

    homepage = "https://github.com/kolypto/j2cli";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      rushmorem
      SuperSandro2000
    ];

    mainProgram = "j2";
  };
}
