{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  fetchpatch,
  glib,
  pkg-config,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glyr";
  version = "1.0.10";

  src = fetchFromGitHub {
    owner = "sahib";
    repo = "glyr";
    rev = finalAttrs.version;
    sha256 = "1miwbqzkhg0v3zysrwh60pj9sv6ci4lzq2vq2hhc6pc6hdyh8xyr";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-mRB0R04CWD+DFkjo5wfvFveUb98+gDAgxWTnrV0K1vk=";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/media-libs/glyr/files/glyr-1.0.10-curl.patch?id=51addb56510c82d88ebac65d9ca4c8ca8e005693";
    })
  ];

  # Compile with cmake >= 4.0
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "CMAKE_MINIMUM_REQUIRED(VERSION 2.6)" \
      "CMAKE_MINIMUM_REQUIRED(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    sqlite
    glib
    curl
  ];

  meta = {
    description = "Music related metadata searchengine";
    homepage = "https://github.com/sahib/glyr";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.sternenseemann ];
    platforms = lib.platforms.unix;
    mainProgram = "glyrc";
  };
})
