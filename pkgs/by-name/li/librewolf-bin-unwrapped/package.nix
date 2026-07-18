{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  alsa-lib,
  autoPatchelfHook,
  config,
  curl,
  dbus-glib,
  gtk3,
  libva,
  libxtst,
  patchelfUnstable, # have to use patchelfUnstable to support --no-clobber-old-sections
  pciutils,
  pipewire,
  wrapGAppsHook3,
  writeText,
}:

let
  binaryName = "librewolf";

  mozillaPlatforms = {
    aarch64-linux = "linux-arm64";
    x86_64-linux = "linux-x86_64";
  };

  throwSystem = throw "Unsupported system: ${stdenv.hostPlatform.system}";

  arch = mozillaPlatforms.${stdenv.hostPlatform.system} or throwSystem;

  policies = config.librewolf.policies or { };

  policiesJson = writeText "librewolf-policies.json" (builtins.toJSON { inherit policies; });

  pname = "librewolf-bin-unwrapped";

  version = "152.0.5-1";
in

stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://codeberg.org/api/packages/librewolf/generic/librewolf/${version}/librewolf-${version}-${arch}-package.tar.xz";

    hash =
      {
        aarch64-linux = "sha256-x9vUXaEtjnY6+mOLbLiXmBr5c7ZmEYRTJK9fDIpfgVs=";
        x86_64-linux = "sha256-9Y0n3UHRK9WgKhKFIMB3CLmh1Gp5aHoIiKxlKNKe5gc=";
      }
      .${stdenv.hostPlatform.system} or throwSystem;
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    autoPatchelfHook
    patchelfUnstable
  ];

  buildInputs = [
    gtk3
    adwaita-icon-theme
    alsa-lib
    dbus-glib
    libxtst
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $prefix/lib $out/bin
    cp -r . $prefix/lib/librewolf-bin-${version}
    ln -s $prefix/lib/librewolf-bin-${version}/librewolf $out/bin/${binaryName}
    # See: https://github.com/mozilla/policy-templates/blob/master/README.md
    mv $out/lib/librewolf-bin-${version}/distribution/policies.json $out/lib/librewolf-bin-${version}/distribution/extra-policies.json
    ${lib.optionalString (config.librewolf.policies or false) ''
      ln -s ${policiesJson} $out/lib/librewolf-bin-${version}/distribution/policies.json
    ''}

    runHook postInstall
  '';

  appendRunpaths = [ "${pipewire}/lib" ];
  # Firefox uses "relrhack" to manually process relocations from a fixed offset
  patchelfFlags = [ "--no-clobber-old-sections" ];

  runtimeDependencies = [
    curl
    libva.out
    pciutils
  ];

  passthru = {
    inherit binaryName;
    applicationName = "LibreWolf";
    ffmpegSupport = true;
    gssSupport = true;
    gtk3 = gtk3;
    libName = "librewolf-bin-${version}";
    updateScript = ./update.sh;
  };

  meta = {
    description = "Fork of Firefox, focused on privacy, security and freedom (upstream binary release)";
    homepage = "https://librewolf.net";
    license = lib.licenses.mpl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      azahi
      eclairevoyant
      dwrege
    ];

    platforms = builtins.attrNames mozillaPlatforms;
    mainProgram = "librewolf";
    hydraPlatforms = [ ];
  };
}
