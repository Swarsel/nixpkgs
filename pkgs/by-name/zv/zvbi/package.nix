{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gitUpdater,
  libiconv,
  libintl,
  testers,
  tzdata,
  validatePkgConfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zvbi";
  version = "0.2.44";

  src = fetchFromGitHub {
    owner = "zapping-vbi";
    repo = "zvbi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-knc9PejugU6K4EQflfz91keZr3ZJqZu2TKFQFFJrxiI=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    autoreconfHook
    validatePkgConfig
  ];

  propagatedBuildInputs = [
    libiconv
    libintl
  ];

  configureFlags = lib.optionals (!lib.systems.equals stdenv.buildPlatform stdenv.hostPlatform) [
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  doCheck =
    stdenv.buildPlatform.canExecute stdenv.hostPlatform
    && !stdenv.hostPlatform.isDarwin
    &&
      # musl does not support TZDIR, used by the tzdata setup hook.
      !stdenv.hostPlatform.isMusl;

  nativeCheckInputs = [
    tzdata
  ];

  enableParallelBuilding = true;

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Vertical Blanking Interval (VBI) utilities";
    homepage = "https://github.com/zapping-vbi/zvbi";
    changelog = "https://github.com/zapping-vbi/zvbi/blob/${finalAttrs.src.rev}/ChangeLog";

    license =
      with lib.licenses;
      AND [
        bsd2
        (OR [
          bsd3
          gpl2Plus
        ])
        gpl2Only
        gpl2Plus
        lgpl21Plus
        lgpl2Plus
        mit
      ];

    maintainers = with lib.maintainers; [ jopejoe1 ];
    pkgConfigModules = [ "zvbi-0.2" ];
  };
})
