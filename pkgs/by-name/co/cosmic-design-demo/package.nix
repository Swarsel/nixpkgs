{
  lib,
  stdenv,
  fetchFromGitHub,
  expat,
  fontconfig,
  freetype,
  just,
  libcosmicAppHook,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-design-demo";
  version = "0-unstable-2024-01-08";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-design-demo";
    rev = "d58cfad46f2982982494fce27fb00ad834dc8992";
    hash = "sha256-nWkiaegSjxgyGlpjXE9vzGjiDORaRCSoZJMDv0jtvaA=";
  };

  nativeBuildInputs = [
    just
    libcosmicAppHook
  ];

  buildInputs = [
    expat
    fontconfig
    freetype
  ];

  cargoHash = "sha256-czfDtiSEmzmcLfpqv0/8sP8zDAEKh+pkQkGXdd5NskM=";
  __structuredAttrs = true;
  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--unstable"
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-design-demo"
  ];

  separateDebugInfo = true;

  meta = {
    description = "Design Demo for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-design-demo";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-design-demo";
    teams = [ lib.teams.cosmic ];
  };
}
