{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "pyxdg";
  version = "0.28";

  src = fetchFromGitLab {
    owner = "xdg";
    repo = "pyxdg";
    rev = "rel-${version}";
    hash = "sha256-TrFQzfkXabmfpGYwhxD1UVY1F645KycfSPPrMJFAe+0=";
    domain = "gitlab.freedesktop.org";
  };

  # Tests failed (errors=4, failures=4) on NixOS
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "xdg" ];

  meta = {
    description = "Contains implementations of freedesktop.org standards";
    homepage = "http://freedesktop.org/wiki/Software/pyxdg";
    license = lib.licenses.lgpl2;
    maintainers = [ ];
  };
}
