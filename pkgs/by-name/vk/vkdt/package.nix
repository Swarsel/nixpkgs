{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cargo,
  clang,
  cmake,
  exiv2,
  ffmpeg,
  freetype,
  glfw,
  glslang,
  libjpeg,
  libmad,
  libvorbis,
  llvm,
  llvmPackages,
  pkg-config,
  pugixml,
  rsync,
  rustPlatform,
  testers,
  vkdt,
  vulkan-headers,
  vulkan-loader,
  vulkan-tools,
  xxd,
}:

stdenv.mkDerivation rec {
  pname = "vkdt";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/hanatos/vkdt/releases/download/${version}/vkdt-${version}.tar.xz";
    hash = "sha256-oLJ5IlWOJoe2vUBaI9nyAhfjuw/lF63ZCdhMSF5D0pE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cargo
    clang
    cmake
    glslang
    llvm
    llvmPackages.openmp
    pkg-config
    rsync
    rustPlatform.cargoSetupHook
    xxd
  ];

  buildInputs = [
    alsa-lib
    exiv2
    ffmpeg
    freetype
    glfw
    libjpeg
    libmad
    libvorbis
    llvmPackages.openmp
    pugixml
    vulkan-headers
    vulkan-loader
    vulkan-tools
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "prefix="
    "VKDT_USE_RAWINPUT=2"
    "VKDT_USE_MCRAW=false" # TODO: support mcraw
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version;
    inherit src cargoRoot;
    hash = "sha256-8+gJVe9A1w9VlQpKjVnO/ZX44GKvh4yXKlGf4HqyW2M=";
  };

  cargoRoot = "src/pipe/modules/i-raw/rawloader-c";
  dontUseCmakeConfigure = true;

  passthru.tests.version = testers.testVersion {
    package = vkdt;
  };

  meta = {
    description = "Vulkan-powered raw image processor";
    homepage = "https://github.com/hanatos/vkdt";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ paperdigits ];
    platforms = lib.platforms.linux;
  };
}
