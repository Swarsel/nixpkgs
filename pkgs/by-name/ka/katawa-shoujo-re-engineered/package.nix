{
  lib,
  copyDesktopItems,
  fetchFromCodeberg,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  renpyMinimal,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "katawa-shoujo-re-engineered";
  version = "2.0.4";

  src = fetchFromCodeberg {
    # GitHub mirror at fleetingheart/ksre
    owner = "fhs";
    repo = "katawa-shoujo-re-engineered";
    rev = "v${finalAttrs.version}";
    hash = "sha256-L8KYGV2sYXqjCppzlO40jzpusN85eOwR+muGK0SiXeA=";
  };

  postPatch = ''
    substituteInPlace game/config.rpy --replace-fail 0.0.0-localbuild ${finalAttrs.version}
  '';

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    renpyMinimal
  ];

  buildPhase = ''
    runHook preBuild

    renpy . compile
    rm -r game/saves

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    phome=$out/share/kataswa-shoujo-re-engineered
    mkdir -p $phome
    cp -r game $phome
    find $phome -type f -name "*.rpy" -delete
    makeWrapper ${lib.getExe renpyMinimal} $out/bin/katawa-shoujo-re-engineered \
      --add-flags $phome --add-flags run
    install -D $src/web-icon.png $out/share/icons/hicolor/512x512/apps/katawa-shoujo-re-engineered.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      desktopName = "Katawa Shoujo: Re-Engineered";
      exec = "katawa-shoujo-re-engineered";
      icon = "katawa-shoujo-re-engineered";
      name = "katawa-shoujo-re-engineered";
      type = "Application";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fan-made modernization of the classic visual novel Katawa Shoujo";
    homepage = "https://www.fhs.sh/projects";

    license = with lib.licenses; [
      # code
      mpl20
      # assets from the original game
      cc-by-nc-nd-30
    ];

    maintainers = with lib.maintainers; [
      quantenzitrone
      rapiteanu
      ulysseszhan
    ];

    platforms = renpyMinimal.meta.platforms;
    mainProgram = "katawa-shoujo-re-engineered";
  };
})
