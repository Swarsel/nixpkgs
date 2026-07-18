{
  lib,
  stdenv,
  fetchurl,
  mutt,
  perlPackages,
}:

stdenv.mkDerivation {
  pname = "grepm";
  version = "0.6";

  src = fetchurl {
    url = "http://www.barsnick.net/sw/grepm";
    sha256 = "0ppprhfw06779hz1b10qvq62gsw73shccsav982dyi6xmqb6jqji";
  };

  buildInputs = [
    perlPackages.grepmail
    mutt
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a $src $out/bin/grepm
    chmod +x $out/bin/grepm
    sed -i \
      -e "s:^grepmail:${perlPackages.grepmail}/bin/grepmail:" \
      -e "s:^\( *\)mutt:\1${mutt}/bin/mutt:" \
      $out/bin/grepm
  '';

  dontUnpack = true;

  meta = {
    description = "Wrapper for grepmail utilizing mutt";
    homepage = "https://www.barsnick.net/sw/grepm.html";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "grepm";
  };
}
