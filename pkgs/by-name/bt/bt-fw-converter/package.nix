{
  lib,
  stdenv,
  fetchurl,
  bluez,
  makeWrapper,
  perl,
  perlPackages,
}:

stdenv.mkDerivation rec {
  pname = "bt-fw-converter";
  version = "2017-02-19";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/winterheart/broadcom-bt-firmware/${rev}/tools/bt-fw-converter.pl";
    sha256 = "c259b414a4a273c89a0fa7159b3ef73d1ea62b6de91c3a7c2fcc832868e39f4b";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    perl
    perlPackages.RegexpGrammars
    bluez
  ];

  installPhase = ''
    install -D -m755 bt-fw-converter.pl $out/bin/bt-fw-converter
    substituteInPlace $out/bin/bt-fw-converter --replace /usr/bin/hex2hcd ${bluez}/bin/hex2hcd
    wrapProgram $out/bin/bt-fw-converter --set PERL5LIB $PERL5LIB
  '';

  rev = "2d8b34402df01c6f7f4b8622de9e8b82fadf4153";

  unpackCmd = ''
    mkdir -p ${pname}-${version}
    cp $src ${pname}-${version}/bt-fw-converter.pl
  '';

  meta = {
    description = "Tool that converts hex to hcd based on inf file";
    homepage = "https://github.com/winterheart/broadcom-bt-firmware/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zraexy ];
    platforms = lib.platforms.linux;
    mainProgram = "bt-fw-converter";
  };
}
