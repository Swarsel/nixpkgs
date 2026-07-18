{
  lib,
  stdenv,
  makeWrapper,
  mrustc,
}:

stdenv.mkDerivation rec {
  inherit (mrustc) src version;
  pname = "mrustc-minicargo";
  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];
  makeFlags = [ "bin/minicargo" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/minicargo $out/bin

    # without it, minicargo defaults to "<minicargo_path>/../bin/mrustc"
    wrapProgram "$out/bin/minicargo" --set MRUSTC_PATH ${mrustc}/bin/mrustc
    runHook postInstall
  '';

  enableParallelBuilding = true;
  makefile = "minicargo.mk";

  meta = {
    inherit (src.meta) homepage;
    description = "Minimalist builder for Rust";

    longDescription = ''
      A minimalist builder for Rust, similar to Cargo but written in C++.
      Designed to work with mrustc to build Rust projects
      (like the Rust compiler itself).
    '';

    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      progval
      r-burns
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "minicargo";
  };
}
