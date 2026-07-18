{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  fetchpatch,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "http-getter";
  version = "0-unstable-2020-12-08";

  src = fetchFromGitHub {
    owner = "tohojo";
    repo = "http-getter";
    rev = "0b20f08133206aaf225946814ceb6b85ab37e136";
    sha256 = "0plyqqwfm9bysichda0w3akbdxf6279wd4mx8mda0c4mxd4xy9nl";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-/fQP0AlEKm/hDj9POGjdAPoW4Z+UExaNnk9PbvW22uE=";
      name = "cmake4-fix";
      url = "https://github.com/tohojo/http-getter/commit/a3646c4cd5f4558f942c2323bbeb83d82a6ce8c1.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ curl ];

  meta = {
    description = "Simple getter for HTTP URLs using cURL";
    homepage = "https://github.com/tohojo/http-getter";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    mainProgram = "http-getter";
  };
}
