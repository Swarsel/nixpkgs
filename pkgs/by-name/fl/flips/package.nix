{
  lib,
  stdenv,
  fetchFromGitea,
  gtk3,
  libdivsufsort,
  llvmPackages,
  pkg-config,
  wrapGAppsHook3,
  withGTK3 ? !stdenv.hostPlatform.isDarwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flips";
  version = "198";

  src = fetchFromGitea {
    owner = "Sir_Walrus";
    repo = "Flips";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zYGDcUbtzstk1sTKgX2Mna0rzH7z6Dic+OvjZLI1umI=";
    domain = "git.disroot.org";
  };

  patches = [ ./use-system-libdivsufsort.patch ];

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optional withGTK3 wrapGAppsHook3;

  buildInputs = [
    libdivsufsort
  ]
  ++ lib.optional withGTK3 gtk3
  ++ lib.optional (withGTK3 && stdenv.hostPlatform.isDarwin) llvmPackages.openmp;

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "TARGET=${if withGTK3 then "gtk" else "cli"}"
  ];

  installPhase = lib.optionalString (!withGTK3) ''
    runHook preInstall
    install -Dm755 flips -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Patcher for IPS and BPS files";
    homepage = "https://git.disroot.org/Sir_Walrus/Flips";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "flips";
  };
})
