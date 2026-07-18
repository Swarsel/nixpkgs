{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  gtk2,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gosmore";
  version = "0-unstable-2014-03-17";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "svn-archive";
    rev = "89b1fbfbc9e9a8b5e78795fd40bdfa60550322fc";
    hash = "sha256-MfuJVsyGWspGNAFD6Ktbbyawb4bPwUITe7WkyFs6JxI=";
    sparseCheckout = [ "applications/rendering/gosmore" ];
  };

  patches = [ ./pointer_int_comparison.patch ];
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libxml2
    gtk2
    curl
  ];

  patchFlags = [
    "-p1"
    "--binary"
  ]; # patch has dos style eol

  prePatch = ''
    sed -e '/curl.types.h/d' -i *.{c,h,hpp,cpp}
    sed -e "24i #include <ctime>" -e "s/data/dat/g" -i jni/libgosm.cpp
  '';

  sourceRoot = "${finalAttrs.src.name}/applications/rendering/gosmore";

  meta = {
    description = "Open Street Map viewer";
    homepage = "https://sourceforge.net/projects/gosmore/";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gosmore";
  };
})
