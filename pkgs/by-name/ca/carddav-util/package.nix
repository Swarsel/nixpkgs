{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3Packages,
}:

stdenv.mkDerivation {
  pname = "carddav";
  version = "0.1-2014-02-26";

  src = fetchFromGitHub {
    owner = "ljanyst";
    repo = "carddav-util";
    rev = "53b181faff5f154bcd180467dd04c0ce69405564";
    sha256 = "sha256-9iRCNDC0FJ+JD2Hk5TC0w4QMjJ9mMtct5WIA35xTGTg=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    requests
    vobject
    lxml
  ];

  doCheck = false; # no test

  installPhase = ''
    mkdir -p $out/bin
    cp $src/carddav-util.py $out/bin

    pythondir="$out/lib/${python3Packages.python.sitePackages}"
    mkdir -p "$pythondir"
    cp $src/carddav.py "$pythondir"
  '';

  preFixup = ''
    wrapProgram "$out/bin/carddav-util.py" \
      --prefix PYTHONPATH : "$PYTHONPATH:$(toPythonPath $out)" \
      --prefix PATH : "$prefix/bin:$PATH"
  '';

  meta = {
    description = "CardDAV import/export utility";
    homepage = "https://github.com/ljanyst/carddav-util";
    license = lib.licenses.isc;
    platforms = lib.platforms.unix;
    mainProgram = "carddav-util.py";
  };
}
