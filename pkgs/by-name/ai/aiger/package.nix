{
  lib,
  stdenv,
  fetchFromGitHub,
  copyPkgconfigItems,
  makePkgconfigItem,
  picosat,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aiger";
  version = "1.9.20";

  src = fetchFromGitHub {
    owner = "arminbiere";
    repo = "aiger";
    tag = "rel-${finalAttrs.version}";
    hash = "sha256-ggkxITuD8phq3VF6tGc/JWQGBhTfPxBdnRobKswYVa4=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  nativeBuildInputs = [ copyPkgconfigItems ];

  env = {
    # copyPkgconfigItems will substitute these in the pkg-config file
    includedir = "${placeholder "dev"}/include";
    libdir = "${placeholder "lib"}/lib";
  };

  postBuild = ''
    $AR rcs libaiger.a aiger.o
  '';

  postInstall = ''
    # test that installing picosat in configurePhase suceeded
    test -f $out/bin/aigbmc

    install -m 444 -Dt $lib/lib libaiger.a
    install -m 444 -Dt $dev/include aiger.h
  '';

  configurePhase = ''
    runHook preConfigure

    # Set up picosat, so we can build 'aigbmc'
    mkdir ../picosat
    ln -s ${picosat}/include/picosat/picosat.h ../picosat/picosat.h
    ln -s ${picosat}/lib/picosat.o             ../picosat/picosat.o
    ln -s ${picosat}/share/picosat.version     ../picosat/VERSION
    ./configure.sh

    runHook postConfigure
  '';

  enableParallelBuilding = true;
  installFlags = [ "PREFIX=${placeholder "out"}" ];

  pkgconfigItems = [
    (makePkgconfigItem {
      inherit (finalAttrs) version;
      inherit (finalAttrs.meta) description;
      cflags = [ "-I\${includedir}" ];

      libs = [
        "-L\${libdir}"
        "-laiger"
      ];

      name = "aiger";

      variables = {
        includedir = "@includedir@";
        libdir = "@libdir@";
      };
    })
  ];

  meta = {
    description = "And-Inverter Graph (AIG) utilities";
    homepage = "https://fmv.jku.at/aiger/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.unix;
  };
})
