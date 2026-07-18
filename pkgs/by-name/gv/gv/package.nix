{
  lib,
  stdenv,
  fetchurl,
  ghostscriptX,
  libiconv,
  libxaw3d,
  libxext,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gv";
  version = "3.7.4";

  src = fetchurl {
    url = "mirror://gnu/gv/gv-${finalAttrs.version}.tar.gz";
    sha256 = "0q8s43z14vxm41pfa8s5h9kyyzk1fkwjhkiwbf2x70alm6rv6qi1";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libxext
    libxaw3d
    ghostscriptX
    perl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  configureFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "--enable-SIGCHLD-fallback"
  ];

  doCheck = true;

  patchPhase = ''
    sed 's|\<gs\>|${ghostscriptX}/bin/gs|g' -i "src/"*.in
    sed 's|"gs"|"${ghostscriptX}/bin/gs"|g' -i "src/"*.c
  '';

  meta = {
    description = "PostScript/PDF document viewer";

    longDescription = ''
      GNU gv allows users to view and navigate through PostScript and
      PDF documents on an X display by providing a graphical user
      interface for the Ghostscript interpreter.
    '';

    homepage = "https://www.gnu.org/software/gv/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
