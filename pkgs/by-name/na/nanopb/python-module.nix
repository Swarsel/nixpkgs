{
  generator-out,
  python3,
  version,
}:
python3.pkgs.buildPythonPackage {
  inherit version;
  pname = "nanopb-python-module";
  src = generator-out;

  propagatedBuildInputs = with python3.pkgs; [
    setuptools
    protobuf
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "nanopb" ];
}
