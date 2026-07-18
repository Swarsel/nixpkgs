{
  lib,
  stdenv,
  binutils,
  dmidecode,
  dnsutils, # dig is recommended for multiple categories
  fetchFromCodeberg,
  file,
  hddtemp,
  installShellFiles,
  ipmitool,
  iproute2,
  kmod,
  lm_sensors,
  makeWrapper,
  mesa-demos,
  pciutils,
  perl,
  perlPackages,
  ps,
  smartmontools,
  tree,
  upower,
  usbutils,
  util-linuxMinimal,
  xdpyinfo,
  xprop,
  xrandr,
  withRecommendedDisplayInformationPrograms ? withRecommends,
  withRecommendedSystemPrograms ? withRecommends,
  withRecommends ? false, # Install (almost) all recommended tools (see --recommends)
}:

let
  prefixPath = programs: "--prefix PATH ':' '${lib.makeBinPath programs}'";
  recommendedSystemPrograms = lib.optionals withRecommendedSystemPrograms [
    util-linuxMinimal
    dmidecode
    file
    hddtemp
    iproute2
    ipmitool
    usbutils
    kmod
    lm_sensors
    smartmontools
    binutils
    tree
    upower
    pciutils
  ];
  recommendedDisplayInformationPrograms = lib.optionals withRecommendedDisplayInformationPrograms [
    mesa-demos
    xdpyinfo
    xprop
    xrandr
  ];
  programs = [
    ps
    dnsutils
  ] # Core programs
  ++ recommendedSystemPrograms
  ++ recommendedDisplayInformationPrograms;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "inxi";
  version = "3.3.41-1";

  src = fetchFromCodeberg {
    owner = "smxi";
    repo = "inxi";
    tag = finalAttrs.version;
    hash = "sha256-JIBBYLpWKawmAEOVr7YoC6oBQdtlYuQcLFlt/ltswpc=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  buildInputs = [ perl ];

  installPhase = ''
    runHook preInstall

    installBin inxi
    wrapProgram $out/bin/inxi \
      --set PERL5LIB "${perlPackages.makePerlPath (with perlPackages; [ CpanelJSONXS ])}" \
      ${prefixPath programs}
    installManPage inxi.1

    runHook postInstall
  '';

  meta = {
    description = "Full featured CLI system information tool";

    longDescription = ''
      inxi is a command line system information script built for console and
      IRC. It is also used a debugging tool for forum technical support to
      quickly ascertain users' system configurations and hardware. inxi shows
      system hardware, CPU, drivers, Xorg, Desktop, Kernel, gcc version(s),
      Processes, RAM usage, and a wide variety of other useful information.
    '';

    homepage = "https://smxi.org/docs/inxi.htm";
    changelog = "https://codeberg.org/smxi/inxi/src/tag/${finalAttrs.version}/inxi.changelog";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      nick-linux
    ];

    platforms = lib.platforms.unix;
    mainProgram = "inxi";
  };
})
