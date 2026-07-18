{
  lib,
  fetchFromGitHub,
  dcraw,
  gdk-pixbuf,
  gimp,
  gobject-introspection,
  libjxl,
  meson,
  ninja,
  # passthru.updateScript
  nix-update-script,
  python3Packages,
  squashfsTools,
  wrapGAppsNoGuiHook,
  xapp,
  # Exclude "raw" for now because dcraw is vulnerable.
  enabledThumbnailers ? [
    "aiff"
    "appimage"
    "epub"
    "gimp"
    "jxl"
    "mp3"
    "ora"
    "vorbiscomment"
  ],
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "xapp-thumbnailers";
  version = "1.2.10";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "xapp-thumbnailers";
    tag = finalAttrs.version;
    hash = "sha256-6ipO1l+K9um8ShIFEHsza5G/yYQxlkBAnYtdgqFC0bI=";
  };

  patches = [ ./meson.patch ];

  postPatch =
    let
      enabledThumbnailerFilenames = map (format: "xapp-${format}-thumbnailer") enabledThumbnailers;
    in
    ''
      for path in files/usr/bin/xapp-*-thumbnailer; do
        filename=$(basename "$path");
        if [[ ! " ${lib.concatStringsSep " " enabledThumbnailerFilenames} " =~ " $filename " ]]; then
          rm "files/usr/bin/$filename"
          rm "files/usr/share/thumbnailers/$filename.thumbnailer"
        fi
      done

      # Make thumbnailer binaries executable (because not all of them are), use absolute paths in thumbnailer files
      for format in ${lib.concatStringsSep " " enabledThumbnailers}; do
        chmod +x files/usr/bin/xapp-$format-thumbnailer
        substituteInPlace files/usr/share/thumbnailers/xapp-$format-thumbnailer.thumbnailer \
          --replace-fail "TryExec=xapp-$format-thumbnailer" "TryExec=${placeholder "out"}/bin/xapp-$format-thumbnailer" \
          --replace-fail "Exec=xapp-$format-thumbnailer" "Exec=${placeholder "out"}/bin/xapp-$format-thumbnailer"
      done
    '';

  nativeBuildInputs = [
    wrapGAppsNoGuiHook
    gobject-introspection
    meson
    ninja
  ];

  buildInputs = [
    gdk-pixbuf
    xapp
  ];

  preFixup =
    let
      runtimeBinPackages =
        lib.optional (builtins.elem "appimage" enabledThumbnailers) squashfsTools
        ++ lib.optional (builtins.elem "gimp" enabledThumbnailers) gimp
        ++ lib.optional (builtins.elem "jxl" enabledThumbnailers) libjxl
        ++ lib.optional (builtins.elem "raw" enabledThumbnailers) dcraw;
    in
    ''
      makeWrapperArgs+=(
        "''${gappsWrapperArgs[@]}" \
        --prefix PATH : '${lib.makeBinPath runtimeBinPackages}'
      )
    '';

  dependencies =
    with python3Packages;
    [
      pillow
      pygobject3
    ]
    ++ lib.optional (builtins.elem "aiff" enabledThumbnailers) mutagen
    ++ lib.optional (builtins.elem "appimage" enabledThumbnailers) pyelftools
    ++ lib.optional (builtins.elem "mp3" enabledThumbnailers) eyed3
    ++ lib.optional (builtins.elem "vorbiscomment" enabledThumbnailers) mutagen;

  # Let the Python wrapper add `gappsWrapperArgs` to avoid two layers of wrapping.
  dontWrapGApps = true;
  pyproject = false;
  pythonImportsCheck = [ "XappThumbnailers" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^(\\d+\\.\\d+\\.\\d+)$"
    ];
  };

  meta = {
    inherit (xapp.meta) platforms;
    description = "Thumbnailers for GTK desktop environments";
    homepage = "https://github.com/linuxmint/xapp-thumbnailers";
    changelog = "https://github.com/linuxmint/xapp-thumbnailers/blob/${finalAttrs.src.tag}/debian/changelog";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ thunze ];
  };
})
