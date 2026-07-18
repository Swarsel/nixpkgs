{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  libffi,
  libxml2,
  libz,
  llvm,
  makeWrapper,
  ncurses,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ivm";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "ivm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pqqUvHK6mPrK1Mir2ILANxtih9OrAKDJPE0nRWc5JOY=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
  ];

  cargoHash = "sha256-voUucoSLsKn0QhCpr52U8x9K4ykkx7iQ3SsHfjrXu+Q=";

  postFixup = ''
    wrapProgram $out/bin/ivm \
      --prefix PATH : ${
        lib.makeBinPath [
          cargo
          llvm.dev
          stdenv.cc
        ]
      } \
      --prefix LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libffi
          libz
          libxml2
          ncurses
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform Inko version manager";
    homepage = "https://github.com/inko-lang/ivm";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.feathecutie ];
    platforms = lib.platforms.unix;
    mainProgram = "ivm";
    teams = [ lib.teams.ngi ];
  };
})
