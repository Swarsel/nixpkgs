{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  alsa-lib,
  autoPatchelfHook,
  config,
  coreutils,
  curl,
  dbus-glib,
  generated,
  gnugrep,
  gnupg,
  gnused,
  gtk3,
  libva,
  libxtst,
  patchelfUnstable, # have to use patchelfUnstable to support --no-clobber-old-sections
  pciutils,
  pipewire,
  runtimeShell,
  undmg,
  wrapGAppsHook3,
  writeScript,
  writeText,
  xidel,
  applicationName ? "Firefox",
  systemLocale ? config.i18n.defaultLocale or "en_US",
}:

let

  inherit (generated) version sources;

  binaryName = "firefox";

  mozillaPlatforms = {
    # bundles are universal and can be re-used for both darwin architectures
    aarch64-darwin = "mac";
    aarch64-linux = "linux-aarch64";
    i686-linux = "linux-i686";
    x86_64-linux = "linux-x86_64";
  };

  arch = mozillaPlatforms.${stdenv.hostPlatform.system};

  isPrefixOf = prefix: string: builtins.substring 0 (builtins.stringLength prefix) string == prefix;

  sourceMatches = locale: source: (isPrefixOf source.locale locale) && source.arch == arch;

  policies = {
    DisableAppUpdate = true;
  }
  // config.firefox.policies or { };

  policiesJson = writeText "firefox-policies.json" (builtins.toJSON { inherit policies; });

  defaultSource = lib.findFirst (sourceMatches "en-US") { } sources;

  mozLocale =
    if systemLocale == "ca_ES@valencia" then
      "ca-valencia"
    else
      lib.replaceStrings [ "_" ] [ "-" ] systemLocale;

  source = lib.findFirst (sourceMatches mozLocale) defaultSource sources;

  pname = "firefox-bin-unwrapped";
in

stdenv.mkDerivation {
  inherit pname version;
  src = fetchurl { inherit (source) url sha256; };

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

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        mkdir -p $out/Applications
        mv Firefox*.app "$out/Applications/${applicationName}.app"
      ''
    else
      ''
        mkdir -p "$prefix/lib/firefox-bin-${version}"
        cp -r * "$prefix/lib/firefox-bin-${version}"

        mkdir -p "$out/bin"
        ln -s "$prefix/lib/firefox-bin-${version}/firefox" "$out/bin/${binaryName}"

        # See: https://github.com/mozilla/policy-templates/blob/master/README.md
        mkdir -p "$out/lib/firefox-bin-${version}/distribution";
        ln -s ${policiesJson} "$out/lib/firefox-bin-${version}/distribution/policies.json";
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
    inherit applicationName binaryName;
    ffmpegSupport = true;
    gssSupport = true;
    gtk3 = gtk3;
    libName = "firefox-bin-${version}";

    # update with:
    # $ nix-shell maintainers/scripts/update.nix --argstr package firefox-bin-unwrapped
    updateScript = import ./update.nix {
      inherit
        pname
        writeScript
        xidel
        coreutils
        gnused
        gnugrep
        gnupg
        curl
        runtimeShell
        ;

      baseUrl = "https://archive.mozilla.org/pub/firefox/releases/";
    };
  };

  meta = {
    description = "Mozilla Firefox, free web browser (binary package)";
    homepage = "https://www.mozilla.org/firefox/";
    changelog = "https://www.firefox.com/en-US/firefox/${version}/releasenotes/";

    license = {
      # "You Are Responsible for the Consequences of Your Use of Firefox"
      # (despite the heading, not an indemnity clause) states the following:
      #
      # > You agree that you will not use Firefox to infringe anyone’s rights
      # > or violate any applicable laws or regulations.
      # >
      # > You will not do anything that interferes with or disrupts Mozilla’s
      # > services or products (or the servers and networks which are connected
      # > to Mozilla’s services).
      #
      # This conflicts with FSF freedom 0: "The freedom to run the program as
      # you wish, for any purpose". (Why should Mozilla be involved in
      # instances where you break your local laws just because you happen to
      # use Firefox whilst doing it?)
      free = false;
      fullName = "Firefox Terms of Use";
      redistributable = true; # since MPL-2.0 still applies
      shortName = "firefox";
      url = "https://www.mozilla.org/about/legal/terms/firefox/";
    };

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      taku0
      lovesegfault
    ];

    platforms = builtins.attrNames mozillaPlatforms;
    mainProgram = binaryName;
    hydraPlatforms = [ ];
  };
}
