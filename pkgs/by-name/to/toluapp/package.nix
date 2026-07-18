{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  lua5_1,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "toluapp";
  version = "1.0.93";

  src = fetchFromGitHub {
    owner = "LuaDist";
    repo = "toluapp";
    tag = finalAttrs.version;
    sha256 = "0zd55bc8smmgk9j4cf0jpibb03lgsvl0knpwhplxbv93mcdnw7s0";
  };

  patches = [
    ./environ-and-linux-is-kinda-posix.patch
    ./headers.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      'cmake_minimum_required ( VERSION 2.8 )' \
      'cmake_minimum_required ( VERSION 4.0 )'
  '';

  strictDeps = true;
  nativeBuildInputs = [ cmake ];
  buildInputs = [ lua5_1 ];
  __structuredAttrs = true;

  meta = {
    description = "Tool to integrate C/Cpp code with Lua";
    homepage = "http://www.codenix.com/~tolua/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = with lib.platforms; unix;
    mainProgram = "tolua++";
  };
})
