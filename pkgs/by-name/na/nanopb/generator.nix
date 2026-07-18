{
  generator-out,
  protobuf,
  python3,
  stdenvNoCC,
  version,
}:
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "nanopb-generator";
  nativeBuildInputs = [ python3.pkgs.wrapPython ];

  propagatedBuildInputs = [
    protobuf
    python3.pkgs.nanopb-proto
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${generator-out}/bin/protoc-gen-nanopb $out/bin/
    cp ${generator-out}/bin/nanopb_generator $out/bin/
    wrapPythonPrograms
    cp ${generator-out}/bin/nanopb_generator.py $out/bin/
  '';

  dontUnpack = true;
}
