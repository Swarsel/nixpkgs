{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  gitUpdater,
  testers,
  util-macros,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "font-util";
  version = "1.4.2";

  src = fetchFromGitLab {
    owner = "font";
    repo = "util";
    tag = "font-util-${finalAttrs.version}";
    hash = "sha256-tB6A5ezfHwzhL3HsWPZjX3/d53Zkm4hBFbxOnTUgNZc=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  nativeBuildInputs = [
    autoreconfHook
    util-macros
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = gitUpdater {
      ignoredVersions = "1_0_1";
      rev-prefix = "font-util-";
    };
  };

  meta = {
    description = "X.Org font package creation/installation utilities";
    homepage = "https://gitlab.freedesktop.org/xorg/font/util";

    license = with lib.licenses; [
      mit
      bsd2
      bsdSourceCode
      mitOpenGroup
      # there is a bit of a diff, but i think its close enough
      # it was probably just adapted a bit to fit to the repository structure
      # or its an older version that the one on spdx
      unicodeTOU
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "fontutil" ];
  };
})
