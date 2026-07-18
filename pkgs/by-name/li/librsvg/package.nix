{
  lib,
  stdenv,
  fetchurl,
  _experimental-update-script-combinators,
  buildPackages,
  bzip2,
  cairo,
  cargo-auditable-cargo-wrapper,
  cargo-c,
  common-updater-scripts,
  dav1d,
  # for passthru.tests
  enlightenment,
  ffmpeg,
  freetype,
  gdk-pixbuf,
  gegl,
  gi-docgen,
  gimp,
  glib,
  gnome,
  gobject-introspection,
  imagemagick,
  imlib2,
  installShellFiles,
  jq,
  libxml2,
  meson,
  mesonEmulatorHook,
  ninja,
  nix,
  pango,
  pkg-config,
  python3Packages,
  rustPlatform,
  rustc,
  shared-mime-info,
  vala,
  vips,
  xfwm4,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
  # Requires building a cdylib and running a target binary
  withPixbufLoader ?
    !stdenv.hostPlatform.isStatic && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "librsvg";
  version = "2.62.3";

  src = fetchurl {
    url = "mirror://gnome/sources/librsvg/${lib.versions.majorMinor finalAttrs.version}/librsvg-${finalAttrs.version}.tar.xz";
    hash = "sha256-frRJsnIqdoAhNW9m3+4yAsIptU7U5qcM5AwJDpf/FvI=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals withIntrospection [
    "devdoc"
  ];

  postPatch = ''
    patchShebangs \
      meson/cargo_wrapper.py \
      meson/makedef.py \
      meson/query-rustc.py

    # Fix thumbnailer path
    substituteInPlace gdk-pixbuf-loader/librsvg.thumbnailer.in \
      --replace-fail '@bindir@/gdk-pixbuf-thumbnailer' '${gdk-pixbuf}/bin/gdk-pixbuf-thumbnailer'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    meson
    ninja
    rustc
    cargo-c
    cargo-auditable-cargo-wrapper
    python3Packages.docutils
    rustPlatform.cargoSetupHook
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    gi-docgen
    vala # vala bindings require GObject introspection
  ]
  ++ lib.optionals (withIntrospection && !stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    libxml2
    bzip2
    dav1d
    pango
    freetype
  ]
  ++ lib.optionals withIntrospection [
    vala # for share/vala/Makefile.vapigen
  ];

  propagatedBuildInputs = [
    glib
    gdk-pixbuf
    cairo
  ];

  mesonFlags = [
    "-Dtriplet=${stdenv.hostPlatform.rust.rustcTarget}"
    (lib.mesonEnable "introspection" withIntrospection)
    (lib.mesonEnable "pixbuf-loader" withPixbufLoader)
    (lib.mesonEnable "vala" withIntrospection)
    (lib.mesonBool "tests" finalAttrs.finalPackage.doCheck)
  ];

  env = {
    PKG_CONFIG_GDK_PIXBUF_2_0_GDK_PIXBUF_QUERY_LOADERS = buildPackages.writeShellScript "gdk-pixbuf-loader-loaders-wrapped" ''
      ${lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (stdenv.hostPlatform.emulator buildPackages)} ${lib.getDev gdk-pixbuf}/bin/gdk-pixbuf-query-loaders
    '';
  };

  # Probably broken MIME type detection on Darwin.
  # Tests fail with imprecise rendering on i686.
  doCheck = !stdenv.hostPlatform.isDarwin && !stdenv.hostPlatform.isi686;

  preCheck = ''
    # Tests complain: Fontconfig error: No writable cache directories
    export HOME=$TMPDIR

    # https://gitlab.gnome.org/GNOME/librsvg/-/issues/258#note_251789
    export XDG_DATA_DIRS=${shared-mime-info}/share:$XDG_DATA_DIRS
  '';

  postInstall =
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    lib.optionalString withPixbufLoader ''
      # Merge gdkpixbuf and librsvg loaders
      GDK_PIXBUF=$out/${gdk-pixbuf.binaryDir}
      cat ${lib.getLib gdk-pixbuf}/${gdk-pixbuf.binaryDir}/loaders.cache $GDK_PIXBUF/loaders.cache > $GDK_PIXBUF/loaders.cache.tmp
      mv $GDK_PIXBUF/loaders.cache.tmp $GDK_PIXBUF/loaders.cache
    ''
    + lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) ''
      installShellCompletion --cmd rsvg-convert \
        --bash <(${emulator} $out/bin/rsvg-convert --completion bash) \
        --fish <(${emulator} $out/bin/rsvg-convert --completion fish) \
        --zsh <(${emulator} $out/bin/rsvg-convert --completion zsh)
    '';

  postFixup = lib.optionalString withIntrospection ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    dontConfigure = true;
    hash = "sha256-9ubfIl9R2BdcAWn7i050KBbb4cMdlakvrKdnjpZCQjA=";
    name = "librsvg-deps-${finalAttrs.version}";
  };

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    tests = {
      inherit
        gegl
        gimp
        imagemagick
        imlib2
        vips
        ;

      inherit (enlightenment) efl;
      inherit xfwm4;
      ffmpeg = ffmpeg.override { withSvg = true; };
    };

    updateScript =
      let
        updateSource = gnome.updateScript {
          packageName = "librsvg";
        };

        updateLockfile = {
          command = [
            "sh"
            "-c"
            ''
              PATH=${
                lib.makeBinPath [
                  common-updater-scripts
                  jq
                  nix
                ]
              }
              update-source-version librsvg --ignore-same-version --source-key=cargoDeps.vendorStaging > /dev/null
            ''
          ];

          # Experimental feature: do not copy!
          supportedFeatures = [ "silent" ];
        };
      in
      _experimental-update-script-combinators.sequence [
        updateSource
        updateLockfile
      ];
  };

  meta = {
    description = "Small library to render SVG images to Cairo surfaces";
    homepage = "https://gitlab.gnome.org/GNOME/librsvg";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "rsvg-convert";
    teams = [ lib.teams.gnome ];
  };
})
