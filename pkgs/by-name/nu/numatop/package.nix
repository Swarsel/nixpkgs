{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  check,
  ncurses,
  nix-update-script,
  numactl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "numatop";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "numatop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-951Sm2zu1mPxMbPdZy+kMH8RAQo0z+Gqf2lxsY/+Lrg=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    numactl
    ncurses
  ];

  doCheck = true;
  nativeCheckInputs = [ check ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for runtime memory locality characterization and analysis of processes and threads on a NUMA system";
    homepage = "https://www.intel.com/content/www/us/en/developer/topic-technology/open/numatop/overview.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ VZstless ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
      "powerpc64-linux"
      "powerpc64le-linux"
    ];

    mainProgram = "numatop";
  };
})
