{
  lib,
  stdenv,
  fetchpatch,
  kernel,
  rr,
}:

/*
  The python script shouldn't be needed for users of this kernel module.
  https://github.com/rr-debugger/rr/blob/master/scripts/zen_workaround.py
  The module itself is called "zen_workaround" (a bit generic unfortunately).
*/
stdenv.mkDerivation {
  inherit (rr) src version;
  pname = "rr-zen_workaround";

  patches = [
    (fetchpatch {
      hash = "sha256-zj5MNwlZmWnagu0tE5Jl5a48wEF0lqNTh4KcbhmOkOo=";
      name = "kernel-6.16.patch";
      stripLen = 2;
      url = "https://github.com/rr-debugger/rr/commit/86aa1ebe03c6a7f60eb65249233f866fd3da8316.diff";
    })
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "-C${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildFlags = [ "modules" ];

  postConfigure = ''
    appendToVar makeFlags "M=$(pwd)"
  '';

  installPhase =
    let
      modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel"; # TODO: longer path?
    in
    ''
      runHook preInstall
      mkdir -p "${modDestDir}"
      cp *.ko "${modDestDir}/"
      find ${modDestDir} -name '*.ko' -exec xz -f '{}' \;
      runHook postInstall
    '';

  hardeningDisable = [ "pic" ];
  sourceRoot = "${rr.src.name}/third-party/zen-pmu-workaround";

  meta = {
    description = "Kernel module supporting the rr debugger on (some) AMD Zen-based CPUs";
    homepage = "https://github.com/rr-debugger/rr/wiki/Zen#kernel-module";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.vcunat ];
    platforms = [ "x86_64-linux" ];
    broken = lib.versionOlder kernel.version "4.19"; # 4.14 breaks and 4.19 works
  };
}
