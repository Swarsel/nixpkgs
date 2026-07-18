{
  lib,
  stdenv,
  fetchurl,
  boost,
  hepmc2,
  lhapdf,
  makeWrapper,
  pythia,
}:

stdenv.mkDerivation {
  pname = "sacrifice";
  version = "1.0.0";

  src = fetchurl {
    url = "https://www.hepforge.org/archive/agile/Sacrifice-1.0.0.tar.gz";
    sha256 = "10bvpq63kmszy1habydwncm0j1dgvam0fkrmvkgbkvf804dcjp6g";
  };

  patches = [
    ./compat.patch
    ./pythia83xx.patch
  ];

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    boost
    hepmc2
    lhapdf
    pythia
  ];

  configureFlags = [
    "--with-HepMC=${hepmc2}"
    "--with-pythia=${pythia}"
  ];

  preConfigure = ''
    substituteInPlace configure --replace HAVE_LCG=yes HAVE_LCG=no
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace configure --replace LIB_SUFFIX=\"so\" LIB_SUFFIX=\"dylib\"
  '';

  postInstall =
    if stdenv.hostPlatform.isDarwin then
      ''
        install_name_tool -add_rpath ${pythia}/lib "$out"/bin/run-pythia
      ''
    else
      ''
        wrapProgram $out/bin/run-pythia \
          --prefix LD_LIBRARY_PATH : "${pythia}/lib"
      '';

  enableParallelBuilding = true;

  meta = {
    description = "Standalone contribution to AGILe for steering Pythia 8";
    homepage = "https://agile.hepforge.org/trac/wiki/Sacrifice";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ veprbl ];
    platforms = lib.platforms.unix;
    mainProgram = "run-pythia";
    # never built on aarch64-darwin since first introduction in nixpkgs
    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64;
  };
}
