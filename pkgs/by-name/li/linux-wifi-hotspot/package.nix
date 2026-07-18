{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  dnsmasq,
  fetchpatch,
  flock,
  gawk,
  getopt,
  glib,
  gnugrep,
  gnused,
  gtk3,
  hostapd,
  iproute2,
  iptables,
  iw,
  kmod,
  makeWrapper,
  networkmanager,
  pkg-config,
  procps,
  qrencode,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "linux-wifi-hotspot";
  version = "4.7.2";

  src = fetchFromGitHub {
    owner = "lakinduakash";
    repo = "linux-wifi-hotspot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+WHYWQ4EyAt+Kq0LHEgC7Kk5HpIqThz6W3PIdW8Wojk=";
  };

  outputs = [ "out" ];

  patches = [
    (fetchpatch {
      hash = "sha256-4xQ3iRUlkNpoxHXABhMIgsoDY9nENN/9FtHD3UMyAhc=";
      url = "https://github.com/lakinduakash/linux-wifi-hotspot/commit/a3fce4b3ee9371eeb7b300fa7e9f291d93986db3.patch";
    })
  ];

  postPatch = ''
    substituteInPlace ./src/scripts/Makefile \
      --replace "etc" "$out/etc"
    substituteInPlace ./src/scripts/wihotspot \
      --replace "/usr" "$out"
    substituteInPlace ./src/desktop/wifihotspot.desktop \
      --replace "/usr" "$out"
    substituteInPlace ./src/scripts/policies/polkit.policy \
      --replace "/usr" "$out"
  '';

  nativeBuildInputs = [
    which
    pkg-config
    makeWrapper
    qrencode
    hostapd
  ];

  buildInputs = [
    glib
    gtk3
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    wrapProgram $out/bin/create_ap \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          dnsmasq
          flock
          gawk
          getopt
          gnugrep
          gnused
          hostapd
          iproute2
          iptables
          iw
          kmod
          networkmanager
          procps
          which
        ]
      }

    wrapProgram $out/bin/wihotspot-gui \
      --prefix PATH : ${lib.makeBinPath [ iw ]} \
      --prefix PATH : "${placeholder "out"}/bin"

    wrapProgram $out/bin/wihotspot \
      --prefix PATH : ${lib.makeBinPath [ iw ]} \
      --prefix PATH : "${placeholder "out"}/bin"
  '';

  meta = {
    description = "Feature-rich wifi hotspot creator for Linux which provides both GUI and command-line interface";
    homepage = "https://github.com/lakinduakash/linux-wifi-hotspot";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      johnrtitor
      onny
    ];

    platforms = lib.platforms.unix;
  };

})
