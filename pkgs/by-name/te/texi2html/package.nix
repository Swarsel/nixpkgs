{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  gettext,
  perl,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "texi2html";
  version = "5.0";

  src = fetchurl {
    url = "mirror://savannah/texi2html/texi2html-${finalAttrs.version}.tar.bz2";
    hash = "sha256-6KmLDuIMSVpquJQ5igZe9YAnLb1aFbGxnovRvInZ+fo=";
  };

  postPatch = ''
    patchShebangs --build separated_to_hash.pl
  '';

  strictDeps = true;

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    gettext
    perl
  ];

  postInstall = ''
    patchShebangs --host --update $out/bin/*
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "Perl script which converts Texinfo source files to HTML output";
    homepage = "https://www.nongnu.org/texi2html/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "texi2html";
  };
})
