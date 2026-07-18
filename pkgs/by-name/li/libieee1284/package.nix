{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  autoconf,
  automake,
  docbook_xml_dtd_412,
  docbook_xsl,
  libtool,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libieee1284";
  version = "0.2.11";

  src = fetchFromGitHub {
    owner = "twaugh";
    repo = "libieee1284";
    rev = "V${builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    sha256 = "0wfv1prmhhpyll9l4g1ij3im7hk9mm96ydw3l9fvhjp3993cdn2x";
  };

  patches = [
    (fetchurl {
      hash = "sha256-sNu0OPBMa9GIwSu754noateF4FZC14f+8YRgYUl13KQ=";
      name = "musl.patch";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/sys-libs/libieee1284/files/libieee1284-0.2.11-don-t-blindly-assume-outb_p-to-be-available.patch?id=dec60bb6900d6ebdaaa6aa1dcb845b30b739f9b5";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    xmlto
    docbook_xml_dtd_412
    docbook_xsl
  ];

  configureFlags = [
    "--without-python"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isMusl && !stdenv.hostPlatform.isx86) [
    # musl always provides <sys/io.h>, even though the functionality
    # is x86-specific.
    # https://www.openwall.com/lists/musl/2024/10/25/2
    "ac_cv_header_sys_io_h=no"
  ];

  prePatch = ''
    ./bootstrap
  '';

  meta = {
    description = "Parallel port communication library";
    homepage = "http://cyberelk.net/tim/software/libieee1284/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.linux;
    mainProgram = "libieee1284_test";
  };
})
