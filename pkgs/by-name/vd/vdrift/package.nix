{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  bullet,
  curl,
  fetchsvn,
  gettext,
  libGL,
  libGLU,
  libvorbis,
  libx11,
  pkg-config,
  scons,
  writeShellScriptBin,
  data ? fetchsvn {
    rev = "1446";
    sha256 = "sha256-KEu49GAOfenPyuaUItt6W9pkuqUNpXgmTSFuc7ThljQ=";
    url = "svn://svn.code.sf.net/p/vdrift/code/vdrift-data";
  },
}:
let
  version = "unstable-2021-09-05";
  bin = stdenv.mkDerivation {
    inherit version;
    pname = "vdrift";

    src = fetchFromGitHub {
      owner = "vdrift";
      repo = "vdrift";
      rev = "7e9e00c8612b2014d491f026dd86b03f9fb04dcd";
      sha256 = "sha256-DrzRF4WzwEXCNALq0jz8nHWZ1oYTEsdrvSYVYI1WkTI=";
    };

    patches = [
      ./0001-Ignore-missing-data-for-installation.patch
    ];

    postPatch = ''
      substituteInPlace src/SConscript \
        --replace-fail sdl2-config "${lib.getExe' (lib.getDev SDL2) "sdl2-config"}"
    '';

    nativeBuildInputs = [
      pkg-config
      scons
    ];

    buildInputs = [
      libGLU
      libGL
      SDL2
      SDL2_image
      libvorbis
      libx11
      bullet
      curl
      gettext
    ];

    buildPhase = ''
      runHook preBuild
      substituteInPlace SConstruct \
        --replace-fail /usr/local "$out" \
        --replace-fail pkg-config "${stdenv.cc.targetPrefix}pkg-config"
      export CXXFLAGS="$(${stdenv.cc.targetPrefix}pkg-config --cflags SDL2_image)"
      scons -j$NIX_BUILD_CORES
      runHook postBuild
    '';

    meta = {
      description = "Car racing game";
      homepage = "https://vdrift.net/";
      license = lib.licenses.gpl2Plus;
      maintainers = [ ];
      platforms = lib.platforms.linux;
      mainProgram = "vdrift";
    };
  };
  wrappedName = "vdrift-${version}-with-data-${toString data.rev}";
in
(writeShellScriptBin "vdrift" ''
  export VDRIFT_DATA_DIRECTORY="${data}"
  exec ${bin}/bin/vdrift "$@"
'').overrideAttrs
  (_: {
    inherit (bin) pname version;
    inherit bin data;
    name = wrappedName;
    unwrapped = bin;

    meta = bin.meta // {
      hydraPlatforms = [ ];
    };
  })
