{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchPypi,
  python,
}:

buildPythonPackage rec {
  pname = "pyasn";
  version = "1.6.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-otVfs+5HlHYJ9QIRylsLrEEahvPJNfuSyksLirfGaP8=";
  };

  doCheck = false; # Tests require internet connection which wont work

  postInstall = ''
    install -dm755 $out/${python.sitePackages}/pyasn/data
    cp $datasrc/data/* $out/${python.sitePackages}/pyasn/data
  '';

  datasrc = fetchFromGitHub {
    hash = "sha256-7zpaxDe5qHUy/ekOJLxKawjaPQnByrOVj+m2bsUqfdg=";
    owner = "hadiasghari";
    repo = "pyasn";
    rev = version;
  };

  format = "setuptools";
  pythonImportsCheck = [ "pyasn" ];

  meta = {
    description = "Offline IP address to Autonomous System Number lookup module";
    homepage = "https://github.com/hadiasghari/pyasn";

    license = with lib.licenses; [
      bsdOriginal
      mit
    ];

    maintainers = with lib.maintainers; [ onny ];
  };
}
