{
  lib,
  fetchFromGitHub,
  buildLua,
  python3Packages,
  unstableGitUpdater,
}:
buildLua {
  pname = "mpv-autosub";
  version = "0-unstable-2021-06-29";

  src = fetchFromGitHub {
    owner = "davidde";
    repo = "mpv-autosub";
    rev = "35115355bd339681f97d067538356c29e5b14afa";
    hash = "sha256-BKT/Tzwl5ZA4fbdc/cxz0+CYc1zyY/KOXc58x5GYow0=";
  };

  preInstall = ''
    substituteInPlace autosub.lua --replace-fail \
      "local subliminal = '/home/david/.local/bin/subliminal'" \
      "local subliminal = '${lib.getExe' python3Packages.subliminal "subliminal"}'"
  '';

  scriptPath = "autosub.lua";
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Fully automatic subtitle downloading for the MPV media player";
    homepage = "https://github.com/davidde/mpv-autosub";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.octvs ];
  };
}
