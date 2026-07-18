{
  brainflow,
  buildPythonPackage,
  nptyping,
  numpy,
  python,
  setuptools,
}:

buildPythonPackage {
  inherit (brainflow)
    pname
    version
    src
    patches
    meta
    ;

  postPatch = ''
    cd python_package
  '';

  buildInputs = [ brainflow ];

  postInstall = ''
    mkdir -p "$out/${python.sitePackages}/brainflow/lib/"
    cp -Tr "${brainflow}/lib" "$out/${python.sitePackages}/brainflow/lib/"
  '';

  build-system = [ setuptools ];

  dependencies = [
    numpy
    nptyping
  ];

  pyproject = true;
  pythonImportsCheck = [ "brainflow" ];
}
