{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fixDarwinDylibNames,
  freetype,
  glib,
  harfbuzz,
  ninja,
  nix-update-script,
  plutosvg,
  sdl3,
  testers,
  validatePkgConfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdl3-ttf";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_ttf";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-g7LfLxs7yr7bezQWPWn8arNuPxCfYLCO4kzXmLRUUSY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    validatePkgConfig
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ fixDarwinDylibNames ];

  buildInputs = [
    sdl3
    freetype
    harfbuzz
    glib
    plutosvg
  ];

  cmakeFlags = [
    (lib.cmakeBool "SDLTTF_STRICT" true)
    (lib.cmakeBool "SDLTTF_HARFBUZZ" true)
    (lib.cmakeBool "SDLTTF_PLUTOSVG" true)
  ];

  doCheck = true;

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "release-(3\\..*)"
      ];
    };
  };

  meta = {
    description = "SDL TrueType font library";
    homepage = "https://github.com/libsdl-org/SDL_ttf";
    changelog = "https://github.com/libsdl-org/SDL_ttf/releases/tag/${toString finalAttrs.src.tag}";
    license = lib.licenses.zlib;

    maintainers = with lib.maintainers; [
      charain
      Emin017
    ];

    platforms = lib.platforms.all;
    pkgConfigModules = [ "sdl3-ttf" ];
    teams = [ lib.teams.sdl ];
  };
})
