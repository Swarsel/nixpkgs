{
  lib,
  stdenv,
  fetchurl,
  lzip,
  runtimeShellPackage,
  testers,
}:

# Note: this package is used for bootstrapping fetchurl, and thus cannot use
# fetchpatch! Any mutable patches (retrieved from GitHub, cgit or any other
# place) that are needed here should be directly included together as regular
# files.

stdenv.mkDerivation (finalAttrs: {
  pname = "ed";
  version = "1.22.5";

  src = fetchurl {
    url = "mirror://gnu/ed/ed-${finalAttrs.version}.tar.lz";
    hash = "sha256-VuEH3cLyna1mkDdsFb+XUVCeHuO4JBcQ5E7b5cOhWMw=";
  };

  strictDeps = true;
  nativeBuildInputs = [ lzip ];
  buildInputs = [ runtimeShellPackage ];

  configureFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  doCheck = true;

  passthru = {
    tests.version = testers.testVersion {
      command = "ed --version";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "GNU implementation of the standard Unix editor";

    longDescription = ''
      GNU ed is a line-oriented text editor. It is used to create, display,
      modify and otherwise manipulate text files, both interactively and via
      shell scripts. A restricted version of ed, red, can only edit files in the
      current directory and cannot execute shell commands. Ed is the 'standard'
      text editor in the sense that it is the original editor for Unix, and thus
      widely available. For most purposes, however, it is superseded by
      full-screen editors such as GNU Emacs or GNU Moe.
    '';

    homepage = "https://www.gnu.org/software/ed/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mdaniels5757 ];
    platforms = lib.platforms.unix;
    mainProgram = "ed";
  };
})
