{
  lib,
  fetchFromGitLab,
  autoreconfHook,
  gitUpdater,
  stdenvNoCC,
  testers,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "util-macros";
  version = "1.20.2";

  src = fetchFromGitLab {
    owner = "util";
    repo = "macros";
    tag = "util-macros-${finalAttrs.version}";
    hash = "sha256-COIWe7GMfbk76/QUIRsN5yvjd6MEarI0j0M+Xa0WoKQ=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;
  nativeBuildInputs = [ autoreconfHook ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = gitUpdater {
      ignoredVersions = "1_0_2";
      rev-prefix = "util-macros-";
    };
  };

  meta = {
    description = "GNU autoconf macros shared across X.Org projects";
    homepage = "https://gitlab.freedesktop.org/xorg/util/macros";

    license =
      with lib.licenses;
      AND [
        hpndSellVariant
        mit
      ];

    maintainers = with lib.maintainers; [
      raboof
      jopejoe1
    ];

    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xorg-macros" ];
  };
})
