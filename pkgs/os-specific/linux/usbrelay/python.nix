{ buildPythonPackage, usbrelay }:

buildPythonPackage {
  inherit (usbrelay) version src;
  inherit (usbrelay) meta;
  pname = "usbrelay_py";
  buildInputs = [ usbrelay ];

  preConfigure = ''
    cd usbrelay_py
  '';

  format = "setuptools";
  pythonImportsCheck = [ "usbrelay_py" ];
}
