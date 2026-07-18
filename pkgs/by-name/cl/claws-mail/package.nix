{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  bison,
  curl,
  dbus,
  dbus-glib,
  enchant,
  flex,
  glib-networking,
  gnupg,
  gnutls,
  gpgme,
  gsettings-desktop-schemas,
  gtk3,
  gumbo,
  libarchive,
  libcanberra-gtk3,
  libetpan,
  libical,
  libnotify,
  librsvg,
  libsm,
  libxml2,
  libytnef,
  networkmanager,
  openldap,
  perl,
  pkg-config,
  poppler,
  python3,
  shared-mime-info,
  valgrind,
  webkitgtk_4_1,
  wrapGAppsHook3,
  enableDbus ? true,
  enableEnchant ? enableSpellcheck,
  enableGnuTLS ? true,
  enableLdap ? true,
  # Arguments to include external libraries
  enableLibSM ? true,
  enableLibetpan ? true,
  enableNetworkManager ? true,
  # Package compatibility: old parameters whose name were not directly derived
  enablePgp ? true,
  # Configure claws-mail's plugins
  enablePluginAcpiNotifier ? true,
  enablePluginAddressKeeper ? true,
  enablePluginArchive ? true,
  enablePluginAttRemover ? true,
  enablePluginAttachWarner ? true,
  enablePluginBogofilter ? true,
  enablePluginBsfilter ? true,
  enablePluginClamd ? true,
  enablePluginDillo ? true,
  enablePluginFancy ? true,
  enablePluginFetchInfo ? true,
  enablePluginKeywordWarner ? true,
  enablePluginLibravatar ? enablePluginRavatar,
  enablePluginLitehtmlViewer ? true,
  enablePluginMailmbox ? true,
  enablePluginManageSieve ? true,
  enablePluginNewMail ? true,
  enablePluginNotification ? (enablePluginNotificationDialogs || enablePluginNotificationSounds),
  enablePluginNotificationDialogs ? true,
  enablePluginNotificationSounds ? true,
  enablePluginPdf ? true,
  enablePluginPdfViewer ? enablePluginPdf,
  enablePluginPerl ? true,
  enablePluginPgp ? enablePgp,
  enablePluginPython ? true,
  enablePluginRavatar ? true,
  enablePluginRssyl ? true,
  enablePluginSmime ? true,
  enablePluginSpamReport ? true,
  enablePluginSpamassassin ? true,
  enablePluginTnefParse ? true,
  enablePluginVcalendar ? true,
  enableSpellcheck ? true,
  enableSvg ? true,
  enableValgrind ? !stdenv.hostPlatform.isDarwin && lib.meta.availableOn stdenv.hostPlatform valgrind,
}:

let
  pythonPkgs = with python3.pkgs; [
    python3
    wrapPython
    pygobject3
  ];

  features = [
    {
      enabled = enablePluginAcpiNotifier;
      flags = [ "acpi_notifier-plugin" ];
    }
    {
      enabled = enablePluginAddressKeeper;
      flags = [ "address_keeper-plugin" ];
    }
    {
      deps = [ libarchive ];
      enabled = enablePluginArchive;
      flags = [ "archive-plugin" ];
    }
    {
      enabled = enablePluginAttRemover;
      flags = [ "att_remover-plugin" ];
    }
    {
      enabled = enablePluginAttachWarner;
      flags = [ "attachwarner-plugin" ];
    }
    {
      enabled = enablePluginBogofilter;
      flags = [ "bogofilter-plugin" ];
    }
    {
      enabled = enablePluginBsfilter;
      flags = [ "bsfilter-plugin" ];
    }
    {
      enabled = enablePluginClamd;
      flags = [ "clamd-plugin" ];
    }
    {
      deps = [
        dbus
        dbus-glib
      ];

      enabled = enableDbus;
      flags = [ "dbus" ];
    }
    {
      enabled = enablePluginDillo;
      flags = [ "dillo-plugin" ];
    }
    {
      deps = [ enchant ];
      enabled = enableEnchant;
      flags = [ "enchant" ];
    }
    {
      deps = [ webkitgtk_4_1 ];
      enabled = enablePluginFancy;
      flags = [ "fancy-plugin" ];
    }
    {
      enabled = enablePluginFetchInfo;
      flags = [ "fetchinfo-plugin" ];
    }
    {
      enabled = enablePluginKeywordWarner;
      flags = [ "keyword_warner-plugin" ];
    }
    {
      deps = [ gnutls ];
      enabled = enableGnuTLS;
      flags = [ "gnutls" ];
    }
    {
      deps = [ openldap ];
      enabled = enableLdap;
      flags = [ "ldap" ];
    }
    {
      deps = [ libetpan ];
      enabled = enableLibetpan;
      flags = [ "libetpan" ];
    }
    {
      enabled = enablePluginLibravatar;
      flags = [ "libravatar-plugin" ];
    }
    {
      deps = [ libsm ];
      enabled = enableLibSM;
      flags = [ "libsm" ];
    }
    {
      deps = [ gumbo ];
      enabled = enablePluginLitehtmlViewer;
      flags = [ "litehtml_viewer-plugin" ];
    }
    {
      enabled = enablePluginMailmbox;
      flags = [ "mailmbox-plugin" ];
    }
    {
      enabled = enablePluginManageSieve;
      flags = [ "managesieve-plugin" ];
    }
    {
      deps = [ networkmanager ];
      enabled = enableNetworkManager;
      flags = [ "networkmanager" ];
    }
    {
      enabled = enablePluginNewMail;
      flags = [ "newmail-plugin" ];
    }
    {
      deps = [ libnotify ] ++ [ libcanberra-gtk3 ];
      enabled = enablePluginNotification;
      flags = [ "notification-plugin" ];
    }
    {
      deps = [ poppler ];
      enabled = enablePluginPdfViewer;
      flags = [ "pdf_viewer-plugin" ];
    }
    {
      deps = [ perl ];
      enabled = enablePluginPerl;
      flags = [ "perl-plugin" ];
    }
    {
      deps = [
        gnupg
        gpgme
      ];

      enabled = enablePluginPgp;

      flags = [
        "pgpcore-plugin"
        "pgpinline-plugin"
        "pgpmime-plugin"
      ];
    }
    {
      enabled = enablePluginPython;
      flags = [ "python-plugin" ];
    }
    {
      deps = [ libxml2 ];
      enabled = enablePluginRssyl;
      flags = [ "rssyl-plugin" ];
    }
    {
      enabled = enablePluginSmime;
      flags = [ "smime-plugin" ];
    }
    {
      enabled = enablePluginSpamReport;
      flags = [ "spam_report-plugin" ];
    }
    {
      enabled = enablePluginSpamassassin;
      flags = [ "spamassassin-plugin" ];
    }
    {
      deps = [ librsvg ];
      enabled = enableSvg;
      flags = [ "svg" ];
    }
    {
      deps = [ libytnef ];
      enabled = enablePluginTnefParse;
      flags = [ "tnef_parse-plugin" ];
    }
    {
      deps = [ valgrind ];
      enabled = enableValgrind;
      flags = [ "valgrind" ];
    }
    {
      deps = [ libical ];
      enabled = enablePluginVcalendar;
      flags = [ "vcalendar-plugin" ];
    }
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "claws-mail";
  version = "4.4.0";

  src = fetchurl {
    url = "https://claws-mail.org/download.php?file=releases/claws-mail-${finalAttrs.version}.tar.xz";
    hash = "sha256-A+BUnV8PzXpZgEGGUkEF0F67XlNNQqS4apqQ9ynKJVs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./mime.patch
  ];

  postPatch = ''
    substituteInPlace configure.ac \
      --replace-fail 'm4_esyscmd([./get-git-version])' '${finalAttrs.version}'
    substituteInPlace src/procmime.c \
      --subst-var-by MIMEROOTDIR ${shared-mime-info}/share
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    bison
    flex
    wrapGAppsHook3
  ];

  buildInputs = [
    curl
    gsettings-desktop-schemas
    glib-networking
    gtk3
  ]
  ++ lib.concatMap (f: lib.optionals f.enabled f.deps) (lib.filter (f: f ? deps) features);

  propagatedBuildInputs = pythonPkgs;

  configureFlags = [
    "--disable-manual" # Missing docbook-tools, e.g., docbook2html
    "--disable-compface" # Missing compface library
    "--disable-jpilot" # Missing jpilot library
  ]
  ++ (map (
    feature: map (flag: lib.strings.enableFeature feature.enabled flag) feature.flags
  ) features);

  preConfigure = ''
    # autotools check tries to dlopen libpython as a requirement for the python plugin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}${python3}/lib
    # generate version without .git
    [ -e version ] || echo "echo ${finalAttrs.version}" > version
  '';

  postInstall = ''
    mkdir -p $out/share/applications
    cp claws-mail.desktop $out/share/applications
  '';

  preFixup = ''
    buildPythonPath "$out $pythonPkgs"
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share" --prefix PYTHONPATH : "$program_PYTHONPATH")
  '';

  enableParallelBuilding = true;

  meta = {
    description = "User-friendly, lightweight, and fast email client";
    homepage = "https://www.claws-mail.org/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      fpletz
      ajs124
    ];

    platforms = lib.platforms.linux;
    mainProgram = "claws-mail";
  };
})
