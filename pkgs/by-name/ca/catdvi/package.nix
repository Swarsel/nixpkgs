{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  fetchpatch,
  texlive,
  texliveInfraOnly,
}:

let
  buildPlatformTools = [
    "pse2unic"
    "adobe2h"
  ];
  tex = texliveInfraOnly.withPackages (ps: [ ps.collection-fontsrecommended ]);
in

stdenv.mkDerivation (finalAttrs: {
  pname = "catdvi";
  version = "0.14";

  src = fetchurl {
    url = with finalAttrs; "http://downloads.sourceforge.net/catdvi/catdvi-${version}.tar.bz2";
    hash = "sha256-orVQVdQuRXp//OGkA7xRidNi4+J+tkw398LPZ+HX+k8=";
  };

  outputs = [ "out" ] ++ lib.optional (with stdenv; buildPlatform.canExecute hostPlatform) "dev";

  patches = [
    # fix error: conflicting types for 'kpathsea_version_string'; have 'char *'
    (fetchpatch {
      hash = "sha256-d3CPDxXdVVLNtKkN0rC2G02dh/bJrRll/nVzQNggwkk=";
      url = "https://sources.debian.org/data/main/c/catdvi/0.14-14/debian/patches/03_kpathsea_version_string_declaration.diff";
    })
  ];

  # fix implicit-int compile error in test code used in configure script
  postPatch = ''
    sed -i 's/^main()/int main()/' configure
  '';

  nativeBuildInputs = [
    texlive.bin.core
    texlive.bin.core.dev
  ];

  buildInputs = [
    tex
  ];

  makeFlags = [
    "catdvi" # to avoid running tests until checkPhase
  ]
  ++ lib.optionals (with stdenv; !buildPlatform.canExecute hostPlatform) (
    map (tool: "--assume-old=${tool}") buildPlatformTools
  );

  preBuild = lib.optionalString (with stdenv; !buildPlatform.canExecute hostPlatform) (
    lib.concatMapStringsSep "\n" (tool: ''
      cp ${lib.getDev buildPackages.catdvi}/bin/${tool} .
    '') buildPlatformTools
  );

  nativeCheckInputs = [
    texlive
  ];

  preInstall = ''
    mkdir -p $out/{bin,man/man1}
  '';

  postInstall =
    lib.optionalString (with stdenv; buildPlatform.canExecute hostPlatform) ''
      mkdir -p $dev/bin
      ${lib.concatMapStringsSep "\n" (tool: ''
        cp ${tool} $dev/bin/
      '') buildPlatformTools}
    ''
    + ''
      mkdir -p $out/share
      ln -s ${tex}/share/texmf-var $out/share/texmf
    '';

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];
  setOutputFlags = false;

  testFlags = [
    "all1"
  ];

  meta = {
    description = "DVI to plain text translator";
    homepage = "https://catdvi.sourceforge.net";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
})
