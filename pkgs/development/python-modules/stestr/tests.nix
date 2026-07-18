{ buildPythonPackage, stestr }:

buildPythonPackage {
  inherit (stestr) version src;
  pname = "stestr-tests";

  preConfigure = ''
    pythonOutputDistPhase() { touch $dist; }
  '';

  nativeCheckInputs = [ stestr ];

  checkPhase = ''
    export PATH=$out/bin:$PATH
    export HOME=$TMPDIR
  '';

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
