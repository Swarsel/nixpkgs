{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  bluez,
  config,
  dhcpcd,
  dnsmasq,
  gobject-introspection,
  gtk3,
  intltool,
  iproute2,
  libpulseaudio,
  librsvg,
  networkmanager,
  obex_data_server,
  pkg-config,
  procps,
  python3Packages,
  wrapGAppsHook3,
  xdg-utils,
  withPulseAudio ? config.pulseaudio or stdenv.hostPlatform.isLinux,
}:

let
  pythonPackages = python3Packages;

in
stdenv.mkDerivation rec {
  pname = "blueman";
  version = "2.4.6";

  src = fetchurl {
    url = "https://github.com/blueman-project/blueman/releases/download/${version}/blueman-${version}.tar.xz";
    sha256 = "sha256-xxKnN/mFWQZoTAdNFm1PEMfxZTeK+WYSgYu//Pv45WY=";
  };

  postPatch = lib.optionalString withPulseAudio ''
    sed -i 's,CDLL(",CDLL("${libpulseaudio.out}/lib/,g' blueman/main/PulseAudioUtils.py
  '';

  nativeBuildInputs = [
    gobject-introspection
    intltool
    pkg-config
    pythonPackages.cython
    pythonPackages.wrapPython
    wrapGAppsHook3
  ];

  buildInputs = [
    bluez
    gtk3
    pythonPackages.python
    librsvg
    adwaita-icon-theme
    networkmanager
    procps
  ]
  ++ pythonPath
  ++ lib.optional withPulseAudio libpulseaudio;

  configureFlags = [
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-systemduserunitdir=${placeholder "out"}/lib/systemd/user"
    # Don't check for runtime dependency `ip` during the configure
    "--disable-runtime-deps-check"
    (lib.enableFeature withPulseAudio "pulseaudio")
  ];

  postFixup = ''
    # This mimics ../../../development/interpreters/python/wrap.sh
    wrapPythonProgramsIn "$out/bin" "$out ''${pythonPath[*]}"
    wrapPythonProgramsIn "$out/libexec" "$out ''${pythonPath[*]}"
  '';

  dontWrapGApps = true;

  makeWrapperArgs = [
    "--prefix PATH ':' ${
      lib.makeBinPath [
        dnsmasq
        dhcpcd
        iproute2
      ]
    }"
    "--suffix PATH ':' ${lib.makeBinPath [ xdg-utils ]}"
    "\${gappsWrapperArgs[@]}"
  ];

  propagatedUserEnvPkgs = [ obex_data_server ];

  pythonPath = with pythonPackages; [
    pygobject3
    pycairo
  ];

  meta = {
    description = "GTK-based Bluetooth Manager";
    homepage = "https://github.com/blueman-project/blueman";
    changelog = "https://github.com/blueman-project/blueman/releases/tag/${version}";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "blueman-manager";
  };
}
