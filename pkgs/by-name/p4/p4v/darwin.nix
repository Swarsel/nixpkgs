{ stdenv, undmg }:

{
  meta,
  pname,
  src,
  version,
}:
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications $out/bin

    # Install Qt applications.
    for f in p4admin.app p4merge.app p4v.app; do
      mv $f $out/Applications
    done

    # Install p4vc separately (it's a tiny shell script).
    mv p4vc $out/bin
    substituteInPlace $out/bin/p4vc \
      --replace /Applications $out/Applications
  '';

  sourceRoot = ".";
}
