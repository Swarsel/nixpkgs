{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  flit-core,
  polib,
}:

buildPythonPackage rec {
  pname = "lingua";
  version = "4.15.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-DhqUZ0HbKIpANhrQT/OP4EvwgZg0uKu4TEtTX+2bpO8=";
  };

  postPatch = ''
    substituteInPlace src/lingua/extract.py \
      --replace-fail SafeConfigParser ConfigParser
  '';

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    click
    polib
  ];

  pyproject = true;
  pythonImportsCheck = [ "lingua" ];

  meta = {
    description = "Translation toolset";
    homepage = "https://github.com/wichert/lingua";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ np ];
  };
}
