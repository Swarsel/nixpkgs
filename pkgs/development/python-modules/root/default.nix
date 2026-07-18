{
  buildPythonPackage,
  python,
  root,
}:

let
  unwrapped = root.override { python3 = python; };
in
buildPythonPackage {
  inherit (unwrapped) pname version meta;
  src = null;

  installPhase = ''
    mkdir -p $out/${python.sitePackages}
    rmdir $out/${python.sitePackages}
    ln -s ${unwrapped}/lib $out/${python.sitePackages}
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  pyproject = false; # disables setuptools/pyproject logic

  # Those namespaces are looked up dynamically via ROOTs CPython extension, so
  # these checks cover the most fragile parts of the package
  pythonImportsCheck = [
    "ROOT"
    "ROOT.Experimental"
    "ROOT.Math"
    "ROOT.RooFit"
    "ROOT.std"
  ];

  # ROOT builds the C++ libraries and CPython extensions in one package and
  # python versions must never be mixed
  passthru = {
    inherit unwrapped;
  };
}
