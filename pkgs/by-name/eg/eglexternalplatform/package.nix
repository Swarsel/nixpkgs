{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  meson,
  ninja,
  nix-update-script,
  replaceVars,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eglexternalplatform";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "eglexternalplatform";
    tag = finalAttrs.version;
    hash = "sha256-tDKh1oSnOSG/XztHHYCwg1tDB7M6olOtJ8te+uan9ko=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
  ];

  __structuredAttrs = true;

  setupHook = replaceVars ./setup-hook.sh {
    jq = lib.getExe buildPackages.jq;
    sponge = lib.getExe' buildPackages.moreutils "sponge";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "EGL External Platform interface";
    homepage = "https://github.com/NVIDIA/eglexternalplatform";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
  };
})
