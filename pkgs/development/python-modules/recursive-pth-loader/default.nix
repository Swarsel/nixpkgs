{
  lib,
  stdenv,
  python,
}:

stdenv.mkDerivation {
  pname = "python-recursive-pth-loader";
  version = "1.0";
  buildInputs = [ python ];
  buildPhase = "${python.pythonOnBuildForHost}/bin/${python.pythonOnBuildForHost.executable} -m compileall .";

  installPhase = ''
    dst=$out/${python.sitePackages}
    mkdir -p $dst
    cp sitecustomize.* $dst/
  '';

  dontUnpack = true;
  patchPhase = "cat ${./sitecustomize.py} > sitecustomize.py";

  meta = {
    description = "Enable recursive processing of pth files anywhere in sys.path";
    license = lib.licenses.mit;
  };
}
