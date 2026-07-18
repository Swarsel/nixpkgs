{
  lib,
  stdenv,
  fetchurl,
  libmnl,
  libnfnetlink,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnetfilter_queue";
  version = "1.0.5";

  src = fetchurl {
    url = "https://www.netfilter.org/projects/libnetfilter_queue/files/libnetfilter_queue-${finalAttrs.version}.tar.bz2";
    sha256 = "1xdra6i4p8jkv943ygjw646qx8df27f7p5852kc06vjx608krzzr";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libmnl
    libnfnetlink
  ];

  meta = {
    description = "Userspace API to packets queued by the kernel packet filter";
    homepage = "https://www.netfilter.org/projects/libnetfilter_queue/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})
