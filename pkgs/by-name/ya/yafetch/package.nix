{
  lib,
  fetchFromGitHub,
  clangStdenv,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "yafetch";
  version = "unstable-2022-04-20";

  src = fetchFromGitHub {
    owner = "kira64xyz";
    repo = "yafetch";
    rev = "a118cfc13f0b475db7c266105c10138d838788b8";
    hash = "sha256-bSJlerfbJG6h5dDwWQKHnVLH6DEuvuUyqaRuJ7jvOsA=";
  };

  # Fixes installation path
  env.PREFIX = placeholder "out";

  # Use the provided NixOS logo automatically
  prePatch = ''
    substituteInPlace ./config.h --replace \
      "#include \"ascii/gnu.h\"" "#include \"ascii/nixos.h\""

    sed '1i#include <array>' -i config.h # gcc12
  '';

  meta = {
    description = "Yet another fetch clone written in C++";
    homepage = "https://github.com/kira64xyz/yafetch";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ashley ];
    platforms = lib.platforms.linux;
    mainProgram = "yafetch";
  };
})
