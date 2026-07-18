{
  lib,
  buildPythonPackage,
  fetchPypi,
  iverilog,
  jinja2,
  ply,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyverilog";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1a74k8r21swmfwvgv4c014y6nbcyl229fspxw89ygsgb0j83xnar";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    substituteInPlace pytest.ini \
      --replace-fail "python_paths" "pythonpath"
  '';

  build-system = [ setuptools ];

  dependencies = [
    jinja2
    ply
    iverilog
  ];

  patchPhase = ''
    # The path to Icarus can still be overridden via an environment variable at runtime.
    substituteInPlace pyverilog/vparser/preprocessor.py \
      --replace-fail \
        "iverilog = 'iverilog'" \
        "iverilog = '${lib.getExe' iverilog "iverilog"}'"
  '';

  pyproject = true;

  meta = {
    description = "Python-based Hardware Design Processing Toolkit for Verilog HDL";
    homepage = "https://github.com/PyHDI/Pyverilog";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
