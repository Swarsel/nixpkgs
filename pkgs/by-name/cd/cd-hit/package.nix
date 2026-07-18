{
  lib,
  stdenv,
  fetchFromGitHub,
  llvmPackages,
  makeWrapper,
  perl,
  perlPackages,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "cd-hit";
  version = "4.8.1";

  src = fetchFromGitHub {
    owner = "weizhongli";
    repo = "cdhit";
    rev = "V${version}";
    sha256 = "032nva6iiwmw59gjipm1mv0xlcckhxsf45mc2qbnv19lbis0q22i";
  };

  nativeBuildInputs = [
    zlib
    makeWrapper
  ];

  buildInputs = lib.optional stdenv.cc.isClang llvmPackages.openmp;

  propagatedBuildInputs = [
    perl
    perlPackages.TextNSP
    perlPackages.ImageMagick
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}c++" # remove once https://github.com/weizhongli/cdhit/pull/114 is merged
    "PREFIX=$(out)/bin"
  ];

  preInstall = "mkdir -p $out/bin";

  postFixup = ''
    wrapProgram $out/bin/FET.pl --prefix PERL5LIB : $PERL5LIB
    wrapProgram $out/bin/plot_2d.pl --prefix PERL5LIB : $PERL5LIB
    wrapProgram $out/bin/clstr_list_sort.pl --prefix PERL5LIB : $PERL5LIB
  '';

  meta = {
    description = "Clustering and comparing protein or nucleotide sequences";
    homepage = "http://weizhongli-lab.org/cd-hit/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.unix;
  };
}
