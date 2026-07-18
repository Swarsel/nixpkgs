{
  lib,
  stdenv,
  fetchurl,
  gnat,
  gnatcoll-core,
  gnatcoll-gmp,
  gnatcoll-iconv,
  gprbuild,
  which,
  xmlada,
  enableShared ? !stdenv.hostPlatform.isStatic,
  # kb database source, if null assume it is pregenerated
  gpr2kbdir ? null,
}:

stdenv.mkDerivation rec {
  pname = "gpr2";
  version = "25.0.0";

  src = fetchurl {
    url = "https://github.com/AdaCore/gpr/releases/download/v${version}/gpr2-with-gprconfig_kb-${lib.versions.majorMinor version}.tgz";
    sha512 = "70fe0fcf541f6d3d90a34cab1638bbc0283dcd765c000406e0cfb73bae1817b30ddfe73f3672247a97c6b6bfc41900bc96a4440ca0c660f9c2f7b9d3cc8f8dcf";
  };

  nativeBuildInputs = [
    which
    gnat
    gprbuild
  ];

  propagatedBuildInputs = [
    xmlada
    gnatcoll-gmp
    gnatcoll-core
    gnatcoll-iconv
  ];

  makeFlags = [
    "prefix=$(out)"
    "PROCESSORS=$(NIX_BUILD_CORES)"
    "ENABLE_SHARED=${lib.boolToYesNo enableShared}"
    "GPR2_BUILD=release"
  ]
  ++ lib.optionals (gpr2kbdir != null) [
    "GPR2KBDIR=${gpr2kbdir}"
  ];

  # fool make into thinking pregenerated targets are up to date
  preBuild = lib.optionalString (gpr2kbdir == null) ''
    touch .build/kb/{*.adb,*.ads,collect_kb}
  '';

  configurePhase = ''
    runHook preConfigure
    make setup "''${makeFlagsArray[@]}" $makeFlags
    runHook postConfigure
  '';

  meta = {
    description = "Framework for analyzing the GNAT Project (GPR) files";
    homepage = "https://github.com/AdaCore/gpr";

    license = with lib.licenses; [
      asl20
      gpl3Only
    ];

    maintainers = with lib.maintainers; [ heijligen ];
    platforms = lib.platforms.all;
    # TODO(@sternenseemann): investigate failure with gnat 13
    broken = lib.versionOlder gnat.version "14";
  };
}
