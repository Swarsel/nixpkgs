{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  libpcap,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ptunnel";
  version = "0.72";

  src = fetchurl {
    url = "https://www.cs.uit.no/~daniels/PingTunnel/PingTunnel-${finalAttrs.version}.tar.gz";
    hash = "sha256-sxj3qn2IkYtiadBUp+JvBPl9iHD0e9Sadsssmcc0B6Q=";
  };

  patches = [
    # fix hyphen-used-as-minus-sign lintian warning in manpage.
    (fetchpatch {
      hash = "sha256-DcMsCZczO+SxOiQuFbdSJn5UH5E4TVf3+vupJ4OurVg=";
      url = "https://salsa.debian.org/alteholz/ptunnel/-/raw/7475a32bc401056aeeb1b99e56b9ae5f1ee9c960/debian/patches/fix_minus_chars_in_man.patch";
    })
    # fix typo in README file.
    (fetchpatch {
      hash = "sha256-9cdOCfr2r9FnTmxJwvoClW5uf27j05zWQLykahKMJQg=";
      url = "https://salsa.debian.org/alteholz/ptunnel/-/raw/7475a32bc401056aeeb1b99e56b9ae5f1ee9c960/debian/patches/fix_typo.diff";
    })
    # reverse parameters to memset.
    (fetchpatch {
      hash = "sha256-dYbuMM0/ZUgi3OxukBIp5rKhlwAjGu7cl/3w3sWr/xU=";
      url = "https://salsa.debian.org/alteholz/ptunnel/-/raw/1dbf9b69507e19c86ac539fd8e3c60fc274717b3/debian/patches/memset-fix.patch";
    })
  ];

  buildInputs = [
    libpcap
  ];

  makeFlags = [
    "prefix=$(out)"
    "CC=cc"
  ];

  meta = {
    description = "Tool for reliably tunneling TCP connections over ICMP echo request and reply packets";
    homepage = "https://www.cs.uit.no/~daniels/PingTunnel";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ptunnel";
  };
})
