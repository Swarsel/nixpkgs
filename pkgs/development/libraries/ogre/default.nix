{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  boost,
  cmake,
  freetype,
  libGL,
  libGLU,
  # linux
  libglut,
  libice,
  libpng,
  libsm,
  libx11,
  libxaw,
  libxmu,
  libxrandr,
  libxrender,
  libxt,
  libxxf86vm,
  nvidia_cg_toolkit,
  ois,
  pkg-config,
  pugixml,
  unzip,
  xorgproto,
  zziplib,
  # optional
  withNvidiaCg ? false,
  withSamples ? false,
}:

let
  common =
    {
      hash,
      imguiHash,
      imguiVersion,
      version,
    }:
    let
      imgui.src = fetchFromGitHub {
        owner = "ocornut";
        repo = "imgui";
        rev = "v${imguiVersion}";
        hash = imguiHash;
      };
    in
    stdenv.mkDerivation {
      inherit version;
      pname = "ogre";

      src = fetchFromGitHub {
        inherit hash;
        owner = "OGRECave";
        repo = "ogre";
        rev = "v${version}";
      };

      postPatch = ''
        mkdir -p build
        cp -R ${imgui.src} build/imgui-${imguiVersion}
        chmod -R u+w build/imgui-${imguiVersion}
      '';

      nativeBuildInputs = [
        cmake
        pkg-config
        unzip
      ];

      buildInputs = [
        SDL2
        boost
        freetype
        libpng
        ois
        pugixml
        zziplib
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        libglut
        libGL
        libGLU
        libice
        libsm
        libx11
        libxaw
        libxmu
        libxrandr
        libxrender
        libxt
        libxxf86vm
        xorgproto
      ]
      ++ lib.optionals withNvidiaCg [
        nvidia_cg_toolkit
      ];

      cmakeFlags = [
        (lib.cmakeBool "OGRE_BUILD_DEPENDENCIES" false)
        (lib.cmakeBool "OGRE_BUILD_SAMPLES" withSamples)
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        (lib.cmakeBool "OGRE_BUILD_LIBS_AS_FRAMEWORKS" false)
      ];

      meta = {
        description = "3D Object-Oriented Graphics Rendering Engine";
        homepage = "https://www.ogre3d.org/";
        license = lib.licenses.mit;

        maintainers = with lib.maintainers; [
          raskin
          wegank
        ];

        platforms = lib.platforms.unix;
      };
    };
in
{
  ogre_13 = common {
    version = "13.6.5";
    hash = "sha256-8VQqePrvf/fleHijVIqWWfwOusGjVR40IIJ13o+HwaE=";
    imguiHash = "sha256-H5rqXZFw+2PfVMsYvAK+K+pxxI8HnUC0GlPhooWgEYM=";
    # https://github.com/OGRECave/ogre/blob/v13.6.5/Components/Overlay/CMakeLists.txt
    imguiVersion = "1.87";
  };

  ogre_14 = common {
    version = "14.5.2";
    hash = "sha256-qI5z6a5WD1WCQZarogQb4c9KRac/szQLsvs/9/5BNCI=";
    imguiHash = "sha256-dkukDP0HD8CHC2ds0kmqy7KiGIh4148hMCyA1QF3IMo=";
    # https://github.com/OGRECave/ogre/blob/v14.5.2/Components/Overlay/CMakeLists.txt
    imguiVersion = "1.91.9b";
  };
}
