{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  cargo,
  curl,
  gettext,
  json_c,
  libiconv,
  libxml2,
  makeWrapper,
  ncurses,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  sqlite,
  stfl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "newsboat";
  version = "2.44";

  src = fetchFromGitHub {
    owner = "newsboat";
    repo = "newsboat";
    tag = "r${finalAttrs.version}";
    hash = "sha256-OV7WpM0NBfqOtFv9Co728UwHut4HhT2u5qgvamy/FAg=";
  };

  # allow other ncurses versions on Darwin
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace config.sh --replace-fail "ncurses5.4" "ncurses"
  '';

  nativeBuildInputs = [
    pkg-config
    asciidoctor
    gettext
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeWrapper
    ncurses
  ];

  buildInputs = [
    stfl
    sqlite
    curl
    libxml2
    json_c
    ncurses
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
    gettext
  ];

  makeFlags = [ "prefix=$(out)" ];

  env = {
    GETTEXT_BIN_DIR = "${lib.getBin gettext}/bin";
    GETTEXT_INCLUDE_DIR = "${lib.getDev gettext}/include";
    # https://github.com/NixOS/nixpkgs/pull/98471#issuecomment-703100014 . We set
    # these for all platforms, since upstream's gettext crate behavior might
    # change in the future.
    GETTEXT_LIB_DIR = "${lib.getLib gettext}/lib";
  };

  doCheck = true;

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    for prog in $out/bin/*; do
      wrapProgram "$prog" --prefix DYLD_LIBRARY_PATH : "${stfl}/lib"
    done
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-HJZnbQ7TDJ9zg0Rav1PCMEymaYy/mSxnrr2gkv4pTX0=";
  };

  checkTarget = "test";
  enableParallelBuilding = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fork of Newsbeuter, an RSS/Atom feed reader for the text console";
    homepage = "https://newsboat.org/";
    changelog = "https://github.com/newsboat/newsboat/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dotlambda
      nicknovitski
    ];

    platforms = lib.platforms.unix;
    mainProgram = "newsboat";
  };
})
