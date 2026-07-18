{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  blas,
  gtk3,
  lapack,
  nix-update-script,
  pkg-config,
  which,
  wrapGAppsHook3,
}:

assert (!blas.isILP64) && (!lapack.isILP64);

stdenv.mkDerivation (finalAttrs: {
  pname = "xnec2c";
  version = "4.4.18";

  src = fetchFromGitHub {
    owner = "KJ7LNW";
    repo = "xnec2c";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bmbSuk/bgjLVs6IOIYpOTdeDCYKTZbsCgMv57cLKsEw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    wrapGAppsHook3
    pkg-config
    which
  ];

  buildInputs = [
    gtk3
    blas
    lapack
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Graphical antenna simulation";
    homepage = "https://www.xnec2c.org/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ mvs ];
    platforms = lib.platforms.unix;
    mainProgram = "xnec2c";
    # Darwin support likely to be fixed upstream in the next release
    broken = stdenv.hostPlatform.isDarwin;
  };
})
