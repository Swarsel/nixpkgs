{
  lib,
  stdenv,
  fetchurl,
  libmnl,
  libnfnetlink,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnetfilter_conntrack";
  version = "1.1.1";

  src = fetchurl {
    url = "https://netfilter.org/projects/libnetfilter_conntrack/files/libnetfilter_conntrack-${finalAttrs.version}.tar.xz";
    hash = "sha256-dp0+r1f6T72wXdEoc7bLmlvnhE2JN+Iitkc4HUQoSCA=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libmnl ];
  propagatedBuildInputs = [ libnfnetlink ];
  enableParallelBuilding = true;
  hardeningDisable = [ "trivialautovarinit" ];

  meta = {
    description = "Userspace library providing an API to the in-kernel connection tracking state table";

    longDescription = ''
      libnetfilter_conntrack is a userspace library providing a programming interface (API) to the
      in-kernel connection tracking state table. The library libnetfilter_conntrack has been
      previously known as libnfnetlink_conntrack and libctnetlink. This library is currently used
      by conntrack-tools among many other applications
    '';

    homepage = "https://netfilter.org/projects/libnetfilter_conntrack/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
