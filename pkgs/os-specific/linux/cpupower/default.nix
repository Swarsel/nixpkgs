{
  lib,
  stdenv,
  buildPackages,
  gettext,
  kernel,
  pciutils,
  which,
}:

stdenv.mkDerivation {
  inherit (kernel) version src patches;
  pname = "cpupower";

  postPatch = ''
    cd tools/power/cpupower
    sed -i 's,/bin/true,${buildPackages.coreutils}/bin/true,' Makefile
    sed -i 's,/bin/pwd,${buildPackages.coreutils}/bin/pwd,' Makefile
    sed -i 's,/usr/bin/install,${buildPackages.coreutils}/bin/install,' Makefile
  '';

  nativeBuildInputs = [
    gettext
    which
  ];

  buildInputs = [ pciutils ];

  makeFlags = [
    "CROSS=${stdenv.cc.targetPrefix}"
    "CC=${stdenv.cc.targetPrefix}cc"
    "LD=${stdenv.cc.targetPrefix}cc"
  ];

  enableParallelBuilding = true;

  installFlags = lib.mapAttrsToList (n: v: "${n}dir=${placeholder "out"}/${v}") {
    bash_completion_ = "share/bash-completion/completions";
    bin = "bin";
    conf = "etc";
    doc = "share/doc/cpupower";
    include = "include";
    lib = "lib";
    libexec = "libexec";
    locale = "share/locale";
    man = "share/man";
    sbin = "sbin";
    unit = "lib/systemd/system";
  };

  meta = {
    description = "Tool to examine and tune power saving features";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    mainProgram = "cpupower";
  };
}
