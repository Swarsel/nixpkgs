{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "misaka";
  version = "2.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1mzc29wwyhyardclj1vg2xsfdibg2lzb7f1azjcxi580ama55wv2";
  };

  propagatedBuildInputs = [ cffi ];
  # The tests require write access to $out
  doCheck = false;
  format = "setuptools";
  propagatedNativeBuildInputs = [ cffi ];

  meta = {
    description = "CFFI binding for Hoedown, a markdown parsing library";
    homepage = "https://misaka.61924.nl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
    mainProgram = "misaka";
  };
}
