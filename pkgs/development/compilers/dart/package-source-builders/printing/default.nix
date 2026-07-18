{
  stdenv,
  pdfium-binaries,
  replaceVars,
}:

{ src, version, ... }:

stdenv.mkDerivation rec {
  inherit version src;
  inherit (src) passthru;
  pname = "printing";

  patches = [
    (replaceVars ./printing.patch {
      inherit pdfium-binaries;
    })
  ];

  postPatch = ''
    popd || true
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  dontBuild = true;

  prePatch = ''
    if [ -d printing ]; then pushd printing; fi
  '';
}
