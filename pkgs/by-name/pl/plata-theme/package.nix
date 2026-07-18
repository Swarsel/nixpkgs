{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  glib,
  gtk-engine-murrine,
  gtk3,
  gtk_engines,
  inkscape,
  libxml2,
  marco,
  parallel,
  pkg-config,
  sassc,
  zip,
  accentColor ? null, # Secondary color for notifications and OSDs (Default: #7986CB = Indigo300)
  cinnamonSupport ? true,
  destructionColor ? null, # Tertiary color for 'destructive' buttons (Default: #F44336 = Red500)
  gnomeFlashbackSupport ? true,
  gnomeShellSupport ? true,
  gtkNextSupport ? false,
  mateSupport ? true,
  openboxSupport ? true,
  plankSupport ? false,
  selectionColor ? null, # Primary color for 'selected-items' (Default: #3F51B5 = Indigo500)
  steamSupport ? false,
  suggestionColor ? null, # Secondary color for 'suggested' buttons (Default: #673AB7 = DPurple500)
  telegramSupport ? false,
  tweetdeckSupport ? false,
  xfceSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plata-theme";
  version = "0.9.9";

  src = fetchFromGitLab {
    owner = "tista500";
    repo = "plata-theme";
    rev = finalAttrs.version;
    hash = "sha256-08Xsnef7LU5NFiDC8Jdve9zqFJYbgKX+cl5mhtOmm8c=";
  };

  postPatch = "patchShebangs .";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    parallel
    sassc
    inkscape
    libxml2
    glib
  ]
  ++ lib.optionals mateSupport [
    gtk3
    marco
  ]
  ++ lib.optional telegramSupport zip;

  buildInputs = [ gtk_engines ];

  configureFlags =
    let
      inherit (lib) enableFeature optional;
      withOptional = value: feat: optional (value != null) "--with-${feat}=${value}";
    in
    [
      "--enable-parallel"
      (enableFeature cinnamonSupport "cinnamon")
      (enableFeature gnomeFlashbackSupport "flashback")
      (enableFeature gnomeShellSupport "gnome")
      (enableFeature openboxSupport "openbox")
      (enableFeature xfceSupport "xfce")
      (enableFeature mateSupport "mate")
      (enableFeature gtkNextSupport "gtk_next")
      (enableFeature plankSupport "plank")
      (enableFeature steamSupport "airforsteam")
      (enableFeature telegramSupport "telegram")
      (enableFeature tweetdeckSupport "tweetdeck")
    ]
    ++ (withOptional selectionColor "selection_color")
    ++ (withOptional accentColor "accent_color")
    ++ (withOptional suggestionColor "suggestion_color")
    ++ (withOptional destructionColor "destruction_color");

  postInstall = ''
    for dest in $out/share/gtksourceview-{3.0,4}/styles; do
      mkdir -p $dest
      cp $out/share/themes/Plata-{Noir,Lumine}/gtksourceview/*.xml $dest
    done
  '';

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  meta = {
    description = "GTK theme based on Material Design Refresh";
    homepage = "https://gitlab.com/tista500/plata-theme";

    license = with lib.licenses; [
      gpl2Plus
      cc-by-sa-40
    ];

    maintainers = with lib.maintainers; [ tadfisher ];
    platforms = lib.platforms.linux;
  };
})
