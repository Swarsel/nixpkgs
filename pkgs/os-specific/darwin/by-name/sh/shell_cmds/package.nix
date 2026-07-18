{
  lib,
  bison,
  clang,
  libedit,
  libresolv,
  libsbuf,
  libutil,
  libxo,
  mkAppleDerivation,
  pkg-config,
  sourceRelease,
}:

let
  # nohup requires vproc_priv.h from launchd
  launchd = sourceRelease "launchd";
in
mkAppleDerivation {
  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    # Fix `mktemp` templates
    substituteInPlace sh/mkbuiltins \
      --replace-fail '-t ka' '-t ka.XXXXXX'
    substituteInPlace sh/mktokens \
      --replace-fail '-t ka' '-t ka.XXXXXX'

    # Update `/etc/locate.rc` paths to point to the store.
    for path in locate/locate/locate.updatedb.8 locate/locate/locate.rc locate/locate/updatedb.sh; do
      substituteInPlace $path --replace-fail '/etc/locate.rc' "$out/etc/locate.rc"
    done
  '';

  nativeBuildInputs = [
    bison
    pkg-config
  ];

  buildInputs = [
    libedit
    libresolv
    libsbuf
    libutil
    libxo
  ];

  env.NIX_CFLAGS_COMPILE = "-I${launchd}/liblaunch";

  postInstall = ''
    # Patch the shebangs to use `sh` from shell_cmds.
    HOST_PATH="$out/bin" patchShebangs --host "$out/bin" "$out/libexec"
  '';

  depsBuildBuild = [ clang ];
  releaseName = "shell_cmds";
  xcodeHash = "sha256-sbgPFMMXgUp+F1IRLiaFto+PsfMHBd23KQ1sQK7tP7A=";

  meta = {
    description = "Darwin shell commands and the Almquist shell";

    license = [
      lib.licenses.bsd2
      lib.licenses.bsd3
    ];
  };
}
