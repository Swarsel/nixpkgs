{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  curl,
  libzen,
  pkg-config,
  zlib,
  # Whether to enable resolving URLs via libcurl
  curlSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmediainfo";
  version = "26.05";

  src = fetchurl {
    url = "https://mediaarea.net/download/source/libmediainfo/${finalAttrs.version}/libmediainfo_${finalAttrs.version}.tar.xz";
    hash = "sha256-wIsth7L7XttFJsKooxfrHyz/RIB+RjGgN8qfmh1FUFQ=";
  };

  postPatch = lib.optionalString (stdenv.cc.targetPrefix != "") ''
    substituteInPlace configure.ac \
      --replace "pkg-config " "${stdenv.cc.targetPrefix}pkg-config "
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ zlib ] ++ lib.optionals curlSupport [ curl ];
  propagatedBuildInputs = [ libzen ];

  configureFlags = [
    "--enable-shared"
  ]
  ++ lib.optionals curlSupport [
    "--with-libcurl"
  ];

  postInstall = ''
    install -vD -m 644 libmediainfo.pc "$out/lib/pkgconfig/libmediainfo.pc"
  '';

  enableParallelBuilding = true;
  sourceRoot = "MediaInfoLib/Project/GNU/Library";

  meta = {
    description = "Shared library for mediainfo";
    homepage = "https://mediaarea.net/";
    changelog = "https://mediaarea.net/MediaInfo/ChangeLog";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.devhell ];
    platforms = lib.platforms.unix;
  };
})
