{
  lib,
  fetchFromGitLab,
  bdfresize,
  dejavu_fonts,
  gitUpdater,
  otf2bdf,
  perl,
  stdenvNoCC,
  unifont,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "console-setup";
  version = "1.242";

  src = fetchFromGitLab {
    owner = "installer-team";
    repo = "console-setup";
    tag = finalAttrs.version;
    hash = "sha256-5PV1Mbg7ZGQsotwnBVz8DI77Y8ULCnoTANqBLlP3YrE=";
    domain = "salsa.debian.org";
  };

  postPatch = ''
    patchShebangs .
    substituteInPlace Fonts/Makefile --replace-fail '/usr/share/fonts/truetype/dejavu/' '${dejavu_fonts}/share/fonts/truetype/'
    ln -s ${unifont}/share/fonts/unifont.bdf Fonts/bdf
    substituteInPlace Fonts/Makefile --replace-fail 'rm -f $(fntdir)/bdf/unifont.bdf' ""
  '';

  buildInputs = [
    bdfresize
    otf2bdf
    perl
  ];

  makeFlags = [ "prefix=${placeholder "out"}" ];
  preBuild = "make -j$NIX_BUILD_CORES bdf";
  enableParallelBuilding = true;
  installTargets = [ "install-linux" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Console font and keymap setup program";
    homepage = "https://salsa.debian.org/installer-team/console-setup";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ners ];
    platforms = lib.platforms.all;
    mainProgram = "setupcon";
  };
})
