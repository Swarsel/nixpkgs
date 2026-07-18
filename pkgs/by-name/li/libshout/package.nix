{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  libtheora,
  libvorbis,
  openssl,
  pkg-config,
  speex,
}:

# need pkg-config so that libshout installs ${out}/lib/pkgconfig/shout.pc

stdenv.mkDerivation (finalAttrs: {
  pname = "libshout";
  version = "2.4.6";

  src = fetchurl {
    url = "https://downloads.xiph.org/releases/libshout/libshout-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-OcvU8O/f3cl1XYghfkf48tcQj6dn+dWKK6JqFtj3yRA=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  patches = [
    # Fixes building libshout with clang. Can be dropped once the following MR is merged:
    # https://gitlab.xiph.org/xiph/icecast-libshout/-/merge_requests/4.
    (fetchpatch {
      hash = "sha256-XjogfcQJBPZX9MPAbNJyXaFZNekL1pabvtTT7N+cz+s=";
      url = "https://gitlab.xiph.org/xiph/icecast-libshout/-/commit/600fa105a799986efcccddfedfdfd3e9a1988cd0.patch";
    })
    (fetchpatch {
      hash = "sha256-0+Wp2Xu59ESCJfoDcwAJHuAJyzMsaBe7f8Js3/ren2g=";
      url = "https://gitlab.xiph.org/xiph/icecast-libshout/-/commit/8ab2de318d55c9d0987ffae7d9b94b365af732c1.patch";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    openssl
    libvorbis
    libtheora
    speex
  ];

  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "Icecast C language bindings";

    longDescription = ''
      Libshout is a library for communicating with and sending data to an icecast
      server.  It handles the socket connection, the timing of the data, and prevents
      bad data from getting to the icecast server.
    '';

    homepage = "https://www.icecast.org";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ jcumming ];
    platforms = with lib.platforms; unix;
    mainProgram = "shout";
  };
})
