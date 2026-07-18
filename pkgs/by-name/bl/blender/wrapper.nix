{
  stdenv,
  blender,
  makeWrapper,
  extraModules ? [ ],
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (blender) version meta;
  pname = blender.pname + "-wrapped";
  src = blender;

  nativeBuildInputs = [
    blender.pythonPackages.wrapPython
    makeWrapper
  ];

  installPhase = ''
    mkdir $out/bin -p
    cp -r $src/share $out/share

    buildPythonPath "''${pythonPath[*]}"

    makeWrapper ${blender}/bin/blender $out/bin/blender \
      --prefix PATH : $program_PATH \
      --prefix PYTHONPATH : $program_PYTHONPATH
  '';

  pythonPath = extraModules;
})
