{
  lib,
  fetchgit,
  libcap,
  libdrm,
  libepoxy,
  minijail,
  nix-update,
  pkg-config,
  pkgsCross,
  protobuf,
  python3,
  rustPlatform,
  unstableGitUpdater,
  virglrenderer,
  wayland,
  wayland-protocols,
  wayland-scanner,
  writeShellScript,
}:

rustPlatform.buildRustPackage {
  pname = "crosvm";
  version = "0-unstable-2026-07-06";

  src = fetchgit {
    url = "https://chromium.googlesource.com/chromiumos/platform/crosvm";
    rev = "1378aabfc63333547e87b788a8204511da243166";
    hash = "sha256-7cfiXOPlNHLIVHBW+y7WnYgdcxErtJeLBxPey/3uA1w=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
    python3
    rustPlatform.bindgenHook
    wayland-scanner
  ];

  buildInputs = [
    libcap
    libdrm
    libepoxy
    minijail
    virglrenderer
    wayland
    wayland-protocols
  ];

  cargoHash = "sha256-bXATbiA+cRi9aOxpaTLRadBjl4O89x+J84byJ4CrsqI=";

  env = {
    CROSVM_USE_SYSTEM_MINIGBM = true;
    CROSVM_USE_SYSTEM_VIRGLRENDERER = true;
  };

  preConfigure = ''
    patchShebangs third_party/minijail/tools/*.py
  '';

  buildFeatures = [ "virgl_renderer" ];
  separateDebugInfo = true;

  passthru = {
    tests = {
      musl = pkgsCross.musl64.crosvm;
    };

    updateScript = writeShellScript "update-crosvm.sh" ''
      set -ue
      ${lib.escapeShellArgs (unstableGitUpdater {
        hardcodeZeroVersion = true;
        url = "https://chromium.googlesource.com/crosvm/crosvm.git";
      })}
      exec ${lib.getExe nix-update} --version=skip
    '';
  };

  meta = {
    description = "Secure virtual machine monitor for KVM";
    homepage = "https://crosvm.dev/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qyliss ];

    platforms = [
      "aarch64-linux"
      "riscv64-linux"
      "x86_64-linux"
    ];

    mainProgram = "crosvm";
  };
}
