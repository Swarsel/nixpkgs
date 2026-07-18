{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "randomfiletree";
  version = "1.2.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-OpLhLsvwk9xrP8FAXGkDDtMts6ikpx8ockvTR/TEmvw=";
    pname = "RandomFileTree";
  };

  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "randomfiletree" ];

  meta = {
    description = "Create a random file/directory tree/structure in python fortesting purposes";
    homepage = "https://pypi.org/project/RandomFileTree/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ twitchy0 ];
  };
})
