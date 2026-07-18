{
  lib,
  stdenv,
  fetchurl,
  boost,
  fastjet,
  fixDarwinDylibNames,
  hepmc,
  lhapdf,
  rsync,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "pythia";
  version = "8.317";

  src = fetchurl {
    url = "https://pythia.org/download/pythia83/pythia${
      builtins.replaceStrings [ "." ] [ "" ] version
    }.tgz";

    sha256 = "sha256-GuVR0U2sSV3f5rNEeSA16+QQ/mxgBNRKM14Ozg50Wt8=";
  };

  nativeBuildInputs = [ rsync ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ fixDarwinDylibNames ];

  buildInputs = [
    boost
    fastjet
    hepmc
    zlib
    lhapdf
  ];

  configureFlags = [
    "--enable-shared"
    "--with-lhapdf6=${lhapdf}"
  ]
  ++ (
    if lib.versions.major hepmc.version == "3" then
      [
        "--with-hepmc3=${hepmc}"
      ]
    else
      [
        "--with-hepmc2=${hepmc}"
      ]
  );

  enableParallelBuilding = true;

  meta = {
    description = "Program for the generation of high-energy physics events";
    homepage = "https://pythia.org";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ veprbl ];
    platforms = lib.platforms.unix;
    mainProgram = "pythia8-config";
  };
}
