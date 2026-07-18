{
  lib,
  makeBinaryWrapper,
  stdenvNoCC,
  zellij-unwrapped,
  extraPackages ? [ ],
}:
stdenvNoCC.mkDerivation {
  inherit (zellij-unwrapped) version meta;
  pname = "zellij";
  src = zellij-unwrapped;
  strictDeps = true;
  nativeBuildInputs = [ makeBinaryWrapper ];

  buildPhase = ''
    cp -rs --no-preserve=mode "$src" "$out"

    wrapProgram "$out/bin/zellij" \
      --prefix PATH : '${lib.makeBinPath extraPackages}'
  '';

  __structuredAttrs = true;
  dontUnpack = true;
}
