{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  guile,
  guile-config,
  makeWrapper,
  pkg-config,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-hall";
  version = "0.4.1";

  src = fetchFromGitLab {
    owner = "a-sassmannshausen";
    repo = "guile-hall";
    rev = finalAttrs.version;
    hash = "sha256-TUCN8kW44X6iGbSJURurcz/Tc2eCH1xgmXH1sMOMOXs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    guile
    pkg-config
    texinfo
    makeWrapper
  ];

  buildInputs = [
    guile
    guile-config
  ];

  doCheck = true;

  postInstall = ''
    wrapProgram $out/bin/hall \
      --prefix GUILE_LOAD_PATH : "$out/${guile.siteDir}:$GUILE_LOAD_PATH" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/${guile.siteCcacheDir}:$GUILE_LOAD_COMPILED_PATH"
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    export HOME=$TMPDIR
    $out/bin/hall --version | grep ${finalAttrs.version} > /dev/null
    runHook postInstallCheck
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Project manager and build tool for GNU guile";
    homepage = "https://gitlab.com/a-sassmannshausen/guile-hall";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = guile.meta.platforms;
    mainProgram = "hall";
  };
})
