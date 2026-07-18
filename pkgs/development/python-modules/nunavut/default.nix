{
  lib,
  buildPythonPackage,
  fetchPypi,
  importlib-resources,
  pydsdl,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "nunavut";
  version = "2.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-23C3biUUs10Po5qzn3EFaq4+HeWCXIC6WzxOKy59VgM=";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace "pydsdl ~= 1.16" "pydsdl"
  '';

  propagatedBuildInputs = [
    importlib-resources
    pydsdl
    pyyaml
  ];

  # allow for writable directory for darwin
  preBuild = ''
    export HOME=$TMPDIR
  '';

  # No tests in pypy package and no git tags yet for release versions, see
  # https://github.com/UAVCAN/nunavut/issues/182
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "nunavut" ];

  meta = {
    description = "UAVCAN DSDL template engine";

    longDescription = ''
      It exposes a pydsdl abstract syntax tree to Jinja2 templates allowing
      authors to generate code, schemas, metadata, documentation, etc.
    '';

    homepage = "https://nunavut.readthedocs.io/";
    changelog = "https://github.com/OpenCyphal/nunavut/releases/tag/${version}";

    license = with lib.licenses; [
      bsd3
      mit
    ];

    maintainers = with lib.maintainers; [ wucke13 ];
    mainProgram = "nnvg";
  };
}
