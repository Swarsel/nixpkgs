{
  lib,
  stdenv,
  cpio,
  replaceVarsWith,
  rpm,
}:

stdenv.mkDerivation {
  buildCommand = ''
    install -Dm755 $script $out/bin/rpmextract
  '';

  name = "rpmextract";

  script = replaceVarsWith {
    src = ./rpmextract.sh;
    isExecutable = true;

    replacements = {
      inherit rpm cpio;
      inherit (stdenv) shell;
    };
  };

  meta = {
    description = "Script to extract RPM archives";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "rpmextract";
  };
}
