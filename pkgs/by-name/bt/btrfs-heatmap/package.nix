{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "btrfs-heatmap";
  version = "9";

  src = fetchFromGitHub {
    owner = "knorrie";
    repo = "btrfs-heatmap";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-yCkuZqWwxrs2eS7EXY6pAOVVVSq7dAMxJtf581gX8vg=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    python3.pkgs.wrapPython
    installShellFiles
  ];

  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

    install -Dm 0755 btrfs-heatmap $out/sbin/btrfs-heatmap
    installManPage man/btrfs-heatmap.1

    buildPythonPath ${python3.pkgs.btrfs}
    patchPythonScript $out/sbin/btrfs-heatmap

    runHook postInstall
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "Visualize the layout of a mounted btrfs";
    homepage = "https://github.com/knorrie/btrfs-heatmap";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sandarukasa
    ];

    platforms = lib.platforms.linux;
    mainProgram = "btrfs-heatmap";
  };
})
