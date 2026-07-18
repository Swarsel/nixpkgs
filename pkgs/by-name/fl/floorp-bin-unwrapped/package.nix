{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  alsa-lib,
  autoPatchelfHook,
  curl,
  dbus-glib,
  gtk3,
  libva,
  libxtst,
  patchelfUnstable, # have to use patchelfUnstable to support --no-clobber-old-sections
  pciutils,
  pipewire,
  undmg,
  wrapGAppsHook3,
  writeText,
}:

let
  inherit (lib.importJSON ./sources.json) version sources;

  binaryName = "floorp";
  policies = {
    DisableAppUpdate = true;
  };

  policiesJson = writeText "floorp-policies.json" (builtins.toJSON { inherit policies; });

in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "floorp-bin-unwrapped";

  src = fetchurl {
    inherit (sources.${stdenv.hostPlatform.system}) url sha256;
  };

  nativeBuildInputs = [
    wrapGAppsHook3
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    autoPatchelfHook
    patchelfUnstable
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    undmg
  ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    gtk3
    adwaita-icon-theme
    alsa-lib
    dbus-glib
    libxtst
  ];

  installPhase = ''
    runHook preInstall
  ''
  + (
    if stdenv.hostPlatform.isDarwin then
      ''
        # it's disabled, so remove these unused files
        rm -v \
          Floorp.app/Contents/Resources/updater.ini \
          Floorp.app/Contents/Library/LaunchServices/org.mozilla.updater
        rm -rvf Floorp.app/Contents/MacOS/updater.app

        mkdir -p $out/Applications
        mv Floorp.app $out/Applications/
      ''
    else
      ''
        # it's disabled, so remove these unused files
        rm -v updater icons/updater.png updater.ini update-settings.ini

        mkdir -p "$prefix/lib" "$prefix/bin"
        cp -r . "$prefix/lib/floorp-bin-${finalAttrs.version}"
        ln -s "$prefix/lib/floorp-bin-${finalAttrs.version}/floorp" "$out/bin/${binaryName}"

        # See: https://github.com/mozilla/policy-templates/blob/master/README.md
        mkdir -p "$out/lib/floorp-bin-${finalAttrs.version}/distribution";
        ln -s ${policiesJson} "$out/lib/floorp-bin-${finalAttrs.version}/distribution/policies.json";
      ''
  )
  + ''
    runHook postInstall
  '';

  appendRunpaths = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    "${pipewire}/lib"
  ];

  # don't break code signing
  dontFixup = stdenv.hostPlatform.isDarwin;
  # Firefox uses "relrhack" to manually process relocations from a fixed offset
  patchelfFlags = [ "--no-clobber-old-sections" ];

  runtimeDependencies = [
    curl
    pciutils
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libva.out
  ];

  sourceRoot = lib.optional stdenv.hostPlatform.isDarwin ".";

  passthru = {
    inherit binaryName;
    applicationName = "Floorp";
    ffmpegSupport = true;
    gssSupport = true;
    gtk3 = gtk3;
    libName = "floorp-bin-${finalAttrs.version}";
    updateScript = ./update.sh;
  };

  meta = {
    description = "Fork of Firefox that seeks balance between versatility, privacy and web openness";
    homepage = "https://floorp.app/";
    changelog = "https://blog.floorp.app/en/release/${finalAttrs.version}/";

    # https://github.com/Floorp-Projects/Floorp#-floorp-license-notices-
    license = with lib.licenses; [
      mpl20
      mit
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      christoph-heiss
    ];

    platforms = builtins.attrNames sources;
    mainProgram = "floorp";
    hydraPlatforms = [ ];
  };
})
