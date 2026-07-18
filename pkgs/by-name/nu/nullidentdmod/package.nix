{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nullidentdmod";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "Ranthrall";
    repo = "nullidentdmod";
    rev = "v${finalAttrs.version}";
    sha256 = "1ahwm5pyidc6m07rh5ls2lc25kafrj233nnbcybprgl7bqdq1b0k";
  };

  installPhase = ''
    mkdir -p $out/bin

    install -Dm755 nullidentdmod $out/bin
  '';

  meta = {
    description = "Simple identd that just replies with a random string or customized userid";
    homepage = "https://github.com/Ranthrall/nullidentdmod";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ das_j ];
    platforms = lib.platforms.linux; # Must be run by systemd
    mainProgram = "nullidentdmod";
  };
})
