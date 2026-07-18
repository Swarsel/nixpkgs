{
  lib,
  stdenv,
  libpsl,
  lzip,
  python3,
}:

stdenv.mkDerivation {
  inherit (libpsl) src version patches;
  pname = "libpsl-with-scripts";
  outputs = libpsl.outputs ++ [ "bin" ];

  postPatch = ''
    patchShebangs src/psl-make-dafsa
  '';

  nativeBuildInputs = [
    lzip
  ];

  buildInputs = [
    python3
  ];

  installPhase =
    let
      linkOutput = oldOutput: newOutput: ''
        cd ${oldOutput}
        find . -type d -print0 | xargs -0 -I{} mkdir -p ${newOutput}/{}
        find . \( -type f -o -type l \) -print0 | xargs -0 -I{} ln -s ${oldOutput}/{} ${newOutput}/{}
        cd -
      '';
      links = lib.concatMapStrings (
        output: linkOutput libpsl.${output} (placeholder output)
      ) libpsl.outputs;
    in
    ''
      runHook preInstall

      ${links}

      install -D src/psl-make-dafsa $bin/bin/psl-make-dafsa
      install -D -m 555 src/psl-make-dafsa.1 $out/share/man/man1/psl-make-dafsa.1

      runHook postInstall
    '';

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
}
