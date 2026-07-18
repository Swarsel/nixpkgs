{
  lib,
  coreutils,
  getopt,
  replaceVarsWith,
  runtimeShell,
}:

replaceVarsWith {
  pname = "lsb_release";
  version = lib.trivial.release;
  src = ./lsb_release.sh;
  dir = "bin";
  isExecutable = true;
  name = "lsb_release"; # Needed for lsb_release script name

  replacements = {
    inherit coreutils getopt runtimeShell;
  };

  meta = {
    description = "Prints certain LSB (Linux Standard Base) and Distribution information";
    license = [ lib.licenses.mit ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "lsb_release";
  };
}
