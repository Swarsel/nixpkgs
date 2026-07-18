{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  c-ares,
  cmake,
  gbenchmark,
  git,
  icu,
  nghttp2,
  nix-update-script,
  openssl,
  readline,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tarantool";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "tarantool";
    repo = "tarantool";
    tag = finalAttrs.version;
    hash = "sha256-fkAjzAS7LV+bME8FeImg1OXNfNhXTH6qb53TzHz4SFY=";
    fetchSubmodules = true;
  };

  postPatch = ''
    cat <<'EOF' > third_party/luajit/test/cmake/GetLinuxDistro.cmake
    macro(GetLinuxDistro output)
      set(''${output} linux)
    endmacro()
    EOF
  '';

  nativeBuildInputs = [
    autoreconfHook
    cmake
  ];

  buildInputs = [
    nghttp2
    git
    readline
    icu
    zlib
    openssl
    c-ares
  ];

  cmakeFlags = [
    "-DENABLE_DIST=ON"
    "-DTARANTOOL_VERSION=${finalAttrs.version}.builtByNix" # expects the commit hash as well
  ];

  nativeCheckInputs = [ gbenchmark ];
  cmakeBuildType = "RelWithDebInfo";

  postAutoreconf = ''
    popd
  '';

  preAutoreconf = ''
    pushd third_party/libunwind
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "In-memory computing platform consisting of a database and an application server";
    homepage = "https://www.tarantool.io/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "tarantool";
  };
})
