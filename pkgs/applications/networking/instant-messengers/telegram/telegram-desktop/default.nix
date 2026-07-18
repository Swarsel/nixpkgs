{
  lib,
  stdenv,
  callPackage,
  geoclue2,
  glib-networking,
  kimageformats,
  qtbase,
  qtimageformats,
  qtsvg,
  qtwayland,
  webkitgtk_4_1,
  wrapGAppsHook3,
  wrapQtAppsHook,
  pname ? "telegram-desktop",
  unwrapped ? callPackage ./unwrapped.nix { inherit stdenv; },
  withWebkit ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit pname;
  inherit (finalAttrs.unwrapped) version meta passthru;
  inherit unwrapped;

  nativeBuildInputs = [
    wrapQtAppsHook
  ]
  ++ lib.optionals withWebkit [
    wrapGAppsHook3
  ];

  buildInputs = [
    qtbase
    qtimageformats
    qtsvg
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    kimageformats
    qtwayland
  ]
  ++ lib.optionals withWebkit [
    glib-networking
  ];

  installPhase = ''
    runHook preInstall
    cp -r "$unwrapped" "$out"
    runHook postInstall
  '';

  preFixup = lib.optionalString (stdenv.hostPlatform.isLinux && withWebkit) ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      wrapQtApp "$out/Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS/${finalAttrs.meta.mainProgram}"
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace $out/share/dbus-1/services/* \
        --replace-fail "$unwrapped" "$out"
    '';

  dontUnpack = true;
  dontWrapGApps = true;
  dontWrapQtApps = stdenv.hostPlatform.isDarwin;

  qtWrapperArgs = lib.optionals (stdenv.hostPlatform.isLinux && withWebkit) [
    "--prefix"
    "LD_LIBRARY_PATH"
    ":"
    (lib.makeLibraryPath [
      geoclue2
      webkitgtk_4_1
    ])
  ];
})
