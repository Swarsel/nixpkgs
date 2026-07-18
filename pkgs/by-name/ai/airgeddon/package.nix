{
  lib,
  stdenv,
  fetchFromGitHub,
  # Required
  aircrack-ng,
  # Undocumented requirements (there is also ping)
  apparmor-bin-utils,
  # Optionals
  # Missing in nixpkgs: beef, hostapd-wpe
  asleap,
  bash,
  bettercap,
  bully,
  ccze,
  coreutils-full,
  crunch,
  curl,
  dnsmasq,
  ethtool,
  ettercap,
  gawk,
  glibc,
  gnugrep,
  gnused,
  hashcat,
  hcxdumptool,
  hcxtools,
  hostapd,
  iproute2,
  iw,
  john,
  lighttpd,
  makeWrapper,
  mdk4,
  ncurses,
  networkmanager,
  nftables,
  openssl,
  pciutils,
  pixiewps,
  procps,
  reaverwps-t6x, # Could be the upstream version too
  systemd,
  tmux,
  # what the author calls "Internals"
  usbutils,
  util-linux,
  wget,
  wireshark-cli,
  xdpyinfo,
  xset,
  # X11 Front
  xterm,
  supportEvilTwin ? false,
  supportHashCracking ? false,
  # Support groups
  supportWpaWps ? true, # Most common use-case
  supportX11 ? false, # Allow using xterm instead of tmux, hard to test
}:
let
  deps = [
    aircrack-ng
    bash
    coreutils-full
    curl
    gawk
    glibc
    gnugrep
    gnused
    iproute2
    iw
    networkmanager
    ncurses
    pciutils
    procps
    tmux
    usbutils
    wget
    ethtool
    util-linux
    ccze
    systemd
  ]
  ++ lib.optionals supportWpaWps [
    bully
    pixiewps
    reaverwps-t6x
  ]
  ++ lib.optionals supportHashCracking [
    asleap
    crunch
    hashcat
    hcxdumptool
    hcxtools
    john
    wireshark-cli
  ]
  ++ lib.optionals supportEvilTwin [
    bettercap
    dnsmasq
    ettercap
    hostapd
    lighttpd
    openssl
    mdk4
    nftables
    apparmor-bin-utils
  ]
  ++ lib.optionals supportX11 [
    xterm
    xset
    xdpyinfo
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "airgeddon";
  version = "11.52";

  src = fetchFromGitHub {
    owner = "v1s1t0r1sh3r3";
    repo = "airgeddon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FQB348wOXi89CnjS32cwZwTewjkguTbhK5Izvh/74Q0=";
  };

  # What these replacings do?
  # - Disable the auto-updates (we'll run from a read-only directory);
  # - Silence the checks (NixOS will enforce the PATH, it will only see the tools as we listed);
  # - Use "tmux", we're not patching XTerm commands;
  # - Remove PWD and $0 references, forcing it to use the paths from store;
  # - Force our PATH to all tmux sessions.
  postPatch = ''
    patchShebangs airgeddon.sh
    sed -i '
      s|AIRGEDDON_AUTO_UPDATE=true|AIRGEDDON_AUTO_UPDATE=false|
      s|AIRGEDDON_SILENT_CHECKS=false|AIRGEDDON_SILENT_CHECKS=true|
      s|AIRGEDDON_WINDOWS_HANDLING=xterm|AIRGEDDON_WINDOWS_HANDLING=tmux|
      ' .airgeddonrc

    sed -Ei '
      s|\$\(pwd\)|${placeholder "out"}/share/airgeddon;scriptfolder=${placeholder "out"}/share/airgeddon/|
      s|\$\{0\}|${placeholder "out"}/bin/airgeddon|
      s|tmux send-keys -t "([^"]+)" "|tmux send-keys -t "\1" "export PATH=\\"$PATH\\"; |
      ' airgeddon.sh
  '';

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  # Install only the interesting files
  installPhase = ''
    runHook preInstall
    install -Dm 755 airgeddon.sh "$out/bin/airgeddon"
    install -dm 755 "$out/share/airgeddon"
    cp -dr .airgeddonrc known_pins.db language_strings.sh plugins/ "$out/share/airgeddon/"
    runHook postInstall
  '';

  # ATTENTION: No need to chdir around, we're removing the occurrences of "$(pwd)"
  postInstall = ''
    wrapProgram $out/bin/airgeddon --prefix PATH : ${lib.makeBinPath deps}
  '';

  meta = {
    description = "Multi-use TUI to audit wireless networks";
    homepage = "https://github.com/v1s1t0r1sh3r3/airgeddon";
    changelog = "https://github.com/v1s1t0r1sh3r3/airgeddon/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "airgeddon";
  };
})
