{
  lib,
  stdenv,
  fetchFromGitHub,
  HTTPDate,
  HTTPMessage,
  # Perl libraries
  LWP,
  LWPProtocolHttps,
  TryTiny,
  URI,
  acpica-tools,
  # Required
  coreutils,
  cpuid,
  curl, # Preferred to using the Perl HTTP libs - according to hw-probe.
  dmidecode,
  drm_info,
  gnugrep,
  gnutar,
  hdparm,
  hplip,
  hwinfo,
  i2c-tools,
  inxi,
  iproute2,
  kmod,
  libva-utils,
  makePerlPath,
  makeWrapper,
  mcelog,
  memtester,
  mesa-demos,
  opensc,
  pciutils,
  perl,
  sane-backends,
  smartmontools,
  sysstat,
  systemd,
  usbutils,
  util-linuxMinimal,
  v4l-utils,
  vulkan-tools,
  xinput,
  xz,
  # Conditionally recommended
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd,
  # Recommended
  withRecommended ? true, # Install recommended tools
  # Suggested
  withSuggested ? false, # Install (most) suggested tools
  # , pnputils # pnputils (lspnp) isn't currently in nixpkgs and appears to be poorly maintained
}:

stdenv.mkDerivation rec {
  pname = "hw-probe";
  version = "1.6.6";

  src = fetchFromGitHub {
    owner = "linuxhw";
    repo = pname;
    rev = version;
    sha256 = "sha256-8dLfk2k7xG2CXMHfMPrpgq43j3ttj5a0bgNPEahl2rQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perl ];
  makeFlags = [ "prefix=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/hw-probe \
      $makeWrapperArgs
  '';

  makeWrapperArgs =
    let
      requiredPrograms = [
        hwinfo
        dmidecode
        smartmontools
        pciutils
        usbutils
        iproute2 # (ip)
        coreutils # (sort)
        gnugrep
        curl
        gnutar
        v4l-utils
        xz
        kmod # (lsmod)
      ];
      recommendedPrograms = [
        mcelog
        hdparm
        acpica-tools
        drm_info
        mesa-demos
        memtester
        sysstat # (iostat)
        util-linuxMinimal # (rfkill)
        xinput
        libva-utils # (vainfo)
        inxi
        vulkan-tools
        i2c-tools
        opensc
      ]
      # cpuid is only compatible with i686 and x86_64
      ++ lib.optional (lib.elem stdenv.hostPlatform.system cpuid.meta.platforms) cpuid;
      conditionallyRecommendedPrograms = lib.optional systemdSupport systemd; # (systemd-analyze)
      suggestedPrograms = [
        hplip # (hp-probe)
        sane-backends # (sane-find-scanner)
        # pnputils # (lspnp)
      ];
      programs =
        requiredPrograms
        ++ conditionallyRecommendedPrograms
        ++ lib.optionals withRecommended recommendedPrograms
        ++ lib.optionals withSuggested suggestedPrograms;
    in
    [
      "--set"
      "PERL5LIB"
      "${makePerlPath [
        LWP
        LWPProtocolHttps
        HTTPMessage
        URI
        HTTPDate
        TryTiny
      ]}"
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath programs}"
    ];

  meta = {
    description = "Probe for hardware, check operability and find drivers";
    homepage = "https://github.com/linuxhw/hw-probe";

    license = with lib.licenses; [
      lgpl21
      bsdOriginal
    ];

    maintainers = with lib.maintainers; [ rehno-lindeque ];
    platforms = with lib.platforms; (linux ++ freebsd ++ netbsd ++ openbsd);
    mainProgram = "hw-probe";
  };
}
