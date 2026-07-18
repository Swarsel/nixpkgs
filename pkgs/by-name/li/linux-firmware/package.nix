{
  lib,
  fetchFromGitLab,
  fetchpatch,
  python3,
  rdfind,
  stdenvNoCC,
  which,
  writeShellScriptBin,
}:
let
  # check-whence.py attempts to call `git ls-files`, but we don't have a .git,
  # because we've just downloaded a snapshot. We do, however, know that we're
  # in a perfectly pristine tree, so we can fake just enough of git to run it.
  gitStub = writeShellScriptBin "git" ''
    if [ "$1" == "ls-files" ]; then
      find -type f -printf "%P\n"
    else
      echo "Git stub called with unexpected arguments $@" >&2
      exit 1
    fi
  '';
in
stdenvNoCC.mkDerivation rec {
  pname = "linux-firmware";
  version = "20260622";

  src = fetchFromGitLab {
    owner = "kernel-firmware";
    repo = "linux-firmware";
    tag = version;
    hash = "sha256-nSoJhgI4hAxtNmnj5M6ticzuBSt9uNAYcmc1VR/yXxE=";
  };

  nativeBuildInputs = [
    gitStub
    python3
    rdfind
    which
  ];

  makeFlags = [ "DESTDIR=$(out)" ];
  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  installTargets = [
    "install"
    "dedup"
  ];

  postUnpack = ''
    patchShebangs .
  '';

  meta = {
    description = "Binary firmware collection packaged by kernel.org";
    homepage = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
    license = lib.licenses.unfreeRedistributableFirmware;
    sourceProvenance = with lib.sourceTypes; [ binaryFirmware ];
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.unix;
    priority = 6; # give precedence to kernel firmware
  };
}
