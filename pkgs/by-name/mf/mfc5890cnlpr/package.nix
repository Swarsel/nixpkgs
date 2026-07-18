{
  lib,
  stdenv,
  fetchurl,
  a2ps,
  coreutils,
  dpkg,
  file,
  gawk,
  ghostscript,
  gnused,
  makeWrapper,
  pkgsi686Linux,
}:

stdenv.mkDerivation rec {
  pname = "mfc5890cnlpr";
  version = "1.1.2-2";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf006168/${pname}-${version}.i386.deb";
    sha256 = "119h3s1p9pv83mrfv6cmxpc0v33xf8c9nw5clj9yafv3aizxy6dp";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  installPhase = ''
    dir=$out/usr/local/Brother/Printer/mfc5890cn

    patchelf --set-interpreter ${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2 $dir/lpd/brmfc5890cnfilter

    wrapProgram $dir/inf/setupPrintcapij \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
        ]
      }

    substituteInPlace $dir/lpd/filtermfc5890cn \
      --replace "/usr/" "$out/usr/"

    wrapProgram $dir/lpd/filtermfc5890cn \
      --prefix PATH : ${
        lib.makeBinPath [
          a2ps
          coreutils
          file
          ghostscript
          gnused
        ]
      }

    substituteInPlace $dir/lpd/psconvertij2 \
      --replace '`which gs`' "${ghostscript}/bin/gs"

    wrapProgram $dir/lpd/psconvertij2 \
      --prefix PATH : ${
        lib.makeBinPath [
          gnused
          gawk
        ]
      }
  '';

  dontBuild = true;

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  meta = {
    description = "Brother MFC-5890CN LPR printer driver";
    homepage = "http://www.brother.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ martinramm ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
