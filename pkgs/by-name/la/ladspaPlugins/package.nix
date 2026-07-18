{
  lib,
  stdenv,
  fetchFromGitHub,
  automake,
  autoreconfHook,
  fftwSinglePrec,
  ladspa-header,
  libxml2,
  perlPackages,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swh-plugins";
  version = "0.4.17";

  src = fetchFromGitHub {
    owner = "swh";
    repo = "ladspa";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-eOtIhNcuItREUShI8JRlBVKfMfovpdfIYu+m37v4KLE=";
  };

  postPatch = ''
    patchShebangs --build . ./metadata/ makestub.pl
    cp ${automake}/share/automake-*/mkinstalldirs .
  '';

  nativeBuildInputs = [
    autoreconfHook
    perlPackages.perl
    perlPackages.XMLParser
    pkg-config
    perlPackages.perl
    perlPackages.XMLParser
  ];

  buildInputs = [
    fftwSinglePrec
    ladspa-header
    libxml2
  ];

  preBuild = ''
    shopt -s globstar
    for f in **/Makefile; do
      substituteInPlace "$f" \
        --replace-quiet 'ranlib' '${stdenv.cc.targetPrefix}ranlib'
    done
    shopt -u globstar
  '';

  meta = {
    description = "LADSPA format audio plugins";
    homepage = "http://plugin.org.uk/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.unix;
  };
})
