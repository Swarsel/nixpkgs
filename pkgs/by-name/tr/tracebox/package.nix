{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  json_c,
  libpcap,
  lua5_1,
  testers,
  tracebox,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tracebox";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "tracebox";
    repo = "tracebox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1KBJ4uXa1XpzEw23IjndZg+aGJXk3PVw8LYKAvxbxCA=";
    fetchSubmodules = true;
  };

  postPatch = ''
    sed -i configure.ac \
      -e 's,$(git describe .*),${finalAttrs.version},'
  '';

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    libpcap
    lua5_1
    json_c
  ];

  configureFlags = [
    "--with-lua=yes"
    "--with-libpcap=yes"
  ];

  env = {
    CXXFLAGS = "-std=c++14";
    LUA_LIB = "-llua";
    PCAPLIB = "-lpcap";
  };

  enableParallelBuilding = true;

  passthru.tests.version = testers.testVersion {
    command = "tracebox -V";
    package = tracebox;
  };

  meta = {
    description = "Middlebox detection tool";
    homepage = "http://www.tracebox.org/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ck3d ];
    platforms = lib.platforms.linux;
  };
})
