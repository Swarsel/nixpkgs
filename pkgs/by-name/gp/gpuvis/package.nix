{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  freetype,
  gtk3,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpuvis";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "mikesart";
    repo = "gpuvis";
    rev = "v${finalAttrs.version}";
    hash = "sha256-a9eAYDsiwyzZc4FAPo0wANysisIT4qCHLh2PrYswJtw=";
  };

  # patch dlopen path for gtk3
  postPatch = ''
    substituteInPlace src/hook_gtk3.h \
      --replace "libgtk-3.so" "${lib.getLib gtk3}/lib/libgtk-3.so"
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wrapGAppsHook3
  ];

  buildInputs = [
    SDL2
    gtk3
    freetype
  ];

  env.CXXFLAGS = toString [
    # GCC 13: error: 'uint32_t' has not been declared
    "-include cstdint"
  ];

  meta = {
    description = "GPU Trace Visualizer";
    homepage = "https://github.com/mikesart/gpuvis";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ emantor ];
    platforms = lib.platforms.linux;
    mainProgram = "gpuvis";
  };
})
