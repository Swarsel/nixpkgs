{
  lib,
  stdenv,
  fetchFromGitHub,
  libjpeg_original,
  makeWrapper,
  perl,
  perlPackages,
}:

stdenv.mkDerivation {
  pname = "jpegrescan";
  version = "unstable-2019-03-27";

  src = fetchFromGitHub {
    owner = "kud";
    repo = "jpegrescan";
    rev = "3a7de06feabeb3c3235c3decbe2557893c1abe51";
    sha256 = "0cnl46z28lkqc5x27b8rpghvagahivrqcfvhzcsv9w1qs8qbd6dm";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perl ];
  propagatedBuildInputs = [ perlPackages.FileSlurp ];

  installPhase = ''
    mkdir -p $out/share/jpegrescan
    mv README.md $out/share/jpegrescan/
    mkdir $out/bin
    mv jpegrescan $out/bin
    chmod +x $out/bin/jpegrescan

    wrapProgram $out/bin/jpegrescan \
      --prefix PATH : "${libjpeg_original}/bin:" \
      --prefix PERL5LIB : $PERL5LIB
  '';

  dontBuild = true;
  dontConfigure = true;

  patchPhase = ''
    patchShebangs jpegrescan
  '';

  meta = {
    description = "Losslessly shrink any JPEG file";
    homepage = "https://github.com/kud/jpegrescan";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ ramkromberg ];
    platforms = lib.platforms.all;
    mainProgram = "jpegrescan";
  };
}
