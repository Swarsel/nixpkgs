{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  coreutils,
  dbus,
  gobject-introspection,
  makeWrapper,
  nix-update-script,
  pcsclite,
  perlPackages,
  pkg-config,
  systemd,
  testers,
  wget,
  wrapGAppsHook3,
  dbusSupport ? stdenv.hostPlatform.isLinux,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd,
  # gui does not cross compile properly
  withGui ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}:

assert systemdSupport -> dbusSupport;

stdenv.mkDerivation (finalAttrs: {
  pname = "pcsc-tools";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "LudovicRousseau";
    repo = "pcsc-tools";
    tag = finalAttrs.version;
    hash = "sha256-xakJwBzsZfqSLZ2wwwQoWtNIC82zOwOtm5CEVx4d+q4=";
  };

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    makeWrapper
    pkg-config
  ]
  ++ lib.optionals withGui [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs =
    lib.optionals dbusSupport [
      dbus
    ]
    ++ [
      perlPackages.perl
      pcsclite
    ]
    ++ lib.optional systemdSupport systemd;

  configureFlags = [
    "--datarootdir=${placeholder "out"}/share"
  ];

  postInstall = ''
    wrapProgram $out/bin/scriptor \
      --set PERL5LIB "${
        with perlPackages;
        makePerlPath [
          ChipcardPCSC
          libintl-perl
        ]
      }"

  ''
  + lib.optionalString withGui ''
    wrapProgram $out/bin/gscriptor \
      ''${makeWrapperArgs[@]} \
      --set PERL5LIB "${
        with perlPackages;
        makePerlPath [
          ChipcardPCSC
          libintl-perl
          GlibObjectIntrospection
          Glib
          Gtk3
          Pango
          Cairo
          CairoGObject
        ]
      }"
  ''
  + ''

    wrapProgram $out/bin/ATR_analysis \
      --set PERL5LIB "${
        with perlPackages;
        makePerlPath [
          ChipcardPCSC
          libintl-perl
        ]
      }"

    wrapProgram $out/bin/pcsc_scan \
      --prefix PATH : "$out/bin:${
        lib.makeBinPath [
          coreutils
          wget
        ]
      }"

    install -Dm444 -t $out/share/pcsc smartcard_list.txt
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  passthru = {
    tests.version = testers.testVersion {
      command = "pcsc_scan -V";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tools used to test a PC/SC driver, card or reader";
    homepage = "https://pcsc-tools.apdu.fr/";
    changelog = "https://github.com/LudovicRousseau/pcsc-tools/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      peterhoeg
      anthonyroussel
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pcsc_scan";
  };
})
