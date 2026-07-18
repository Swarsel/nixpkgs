{
  lib,
  stdenv,
  fetchFromGitHub,
  acpica-tools,
  bc,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  linuxPackages,
  makeWrapper,
  pciutils,
  powertop,
  unstableGitUpdater,
  util-linux,
  xset,
  xxd,
}:

let
  deps = lib.makeBinPath [
    acpica-tools
    bc
    coreutils
    gawk
    gnugrep
    gnused
    linuxPackages.turbostat
    pciutils
    powertop
    util-linux
    xset
    xxd
  ];
in
stdenv.mkDerivation {
  pname = "s0ix-selftest-tool";
  version = "0-unstable-2025-07-01";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "S0ixSelftestTool";
    rev = "2707d34bf8130feb21e5902efbdecbd2dc915148";
    hash = "sha256-2quAiVYt6elULJTqMFhnciNWork6ViTWcPTRJQfvu+I=";
  };

  # don't use the bundled turbostat binary
  postPatch = ''
    substituteInPlace s0ix-selftest-tool.sh --replace-fail '"$DIR"/turbostat' 'turbostat'
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm555 s0ix-selftest-tool.sh "$out/bin/s0ix-selftest-tool"
    wrapProgram "$out/bin/s0ix-selftest-tool" --prefix PATH : ${deps}
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Tool for testing the S2idle path CPU Package C-state and S0ix failures";
    homepage = "https://github.com/intel/S0ixSelftestTool";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ adamcstephens ];
    platforms = lib.platforms.linux;
    mainProgram = "s0ix-selftest-tool";
  };
}
