{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vimer";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "susam";
    repo = "vimer";
    rev = finalAttrs.version;
    sha256 = "01qhr3i7wasbaxvms39c81infpry2vk0nzh7r5m5b9p713p0phsi";
  };

  installPhase = ''
    mkdir $out/bin/ -p
    cp vimer $out/bin/
    chmod +x $out/bin/vimer
  '';

  meta = {
    description = ''
      A convenience wrapper for gvim/mvim --remote(-tab)-silent to open files
      in an existing instance of GVim or MacVim.
    '';

    homepage = "https://github.com/susam/vimer";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = lib.platforms.all;
    mainProgram = "vimer";
  };

})
