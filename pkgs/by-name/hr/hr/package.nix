{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hr";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "LuRsT";
    repo = "hr";
    rev = finalAttrs.version;
    sha256 = "sha256-05num4v8C3n+uieKQJVLOzu9OOMBsUMPqq08Ou6gmYQ=";
  };

  preInstall = ''
    mkdir -p $out/{bin,share}
  '';

  dontBuild = true;

  installFlags = [
    "PREFIX=$(out)"
    "MANPREFIX=$(out)/share"
  ];

  meta = {
    description = "Horizontal bar for your terminal";
    homepage = "https://github.com/LuRsT/hr";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = lib.platforms.unix;
    mainProgram = "hr";
  };
})
