{
  lib,
  stdenv,
  fetchurl,
  curl,
  patchelf,
  perl,
  swi-prolog,
  tcsh,
}:

stdenv.mkDerivation rec {
  pname = "TPTP";
  version = "9.1.0";

  src = fetchurl {
    hash = "sha256-KylCpKEdjvXTzYU2MOi0FDrr4e6je2YB366+dxy3Xmo=";

    urls = [
      "https://tptp.org/TPTP/Distribution/TPTP-v${version}.tgz"
      "https://tptp.org/TPTP/Archive/TPTP-v${version}.tgz"
    ];
  };

  nativeBuildInputs = [
    patchelf
    swi-prolog
  ];

  buildInputs = [
    tcsh
    swi-prolog
    perl
  ];

  installPhase = ''
    sharedir=$out/share/tptp

    mkdir -p $sharedir
    cp -r ./ $sharedir

    export TPTP=$sharedir

    tcsh $sharedir/Scripts/tptp2T_install -default

    substituteInPlace $sharedir/TPTP2X/tptp2X_install --replace /bin/mv mv
    tcsh $sharedir/TPTP2X/tptp2X_install -default

    patchelf --interpreter $(cat $NIX_CC/nix-support/dynamic-linker) --set-rpath ${lib.getLib curl}/lib $sharedir/Scripts/tptp4X

    mkdir -p $out/bin
    ln -s $sharedir/TPTP2X/tptp2X $out/bin
    ln -s $sharedir/Scripts/tptp2T $out/bin
    ln -s $sharedir/Scripts/tptp4X $out/bin
  '';

  meta = {
    description = "Thousands of problems for theorem provers and tools";
    homepage = "https://tptp.org/TPTP/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.all;
    # 6.3 GiB of data. Installation is unpacking and editing a few files.
    # No sense in letting Hydra build it.
    # Also, it is unclear what is covered by "verbatim" - we will edit configs
    hydraPlatforms = [ ];
  };
}
