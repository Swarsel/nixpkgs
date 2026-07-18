{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  nix-update-script,
  fanotifySupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "inotify-tools";
  version = "4.25.9.0";

  src = fetchFromGitHub {
    owner = "inotify-tools";
    repo = "inotify-tools";
    rev = finalAttrs.version;
    hash = "sha256-u7bnFmSEXNGVZTJ71kOTscQLymbjJblJCIY9Uj7/3mM=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  configureFlags = [
    (lib.enableFeature fanotifySupport "fanotify")
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    homepage = "https://github.com/inotify-tools/inotify-tools/wiki";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pSub
    ];

    platforms = lib.platforms.linux;
  };
})
