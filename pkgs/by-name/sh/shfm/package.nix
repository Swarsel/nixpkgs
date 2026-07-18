{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shfm";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = "shfm";
    rev = finalAttrs.version;
    hash = "sha256-ilVrUFfyzOZgjbBTqlHA9hLaTHw1xHFo1Y/tjXygNEs=";
  };

  postPatch = ''
    patchShebangs ./shfm
  '';

  installPhase = ''
    runHook preInstall
    install -D shfm --target-directory $out/bin/
    install -D README --target-directory $out/share/doc/shfm/
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "POSIX-shell based file manager";
    homepage = "https://github.com/dylanaraps/shfm";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "shfm";
  };
})
