{
  lib,
  fetchFromGitHub,
  mkLibretroCore,
  withProfile ? "accuracy",
}:
mkLibretroCore {
  version = "0-unstable-2026-04-20";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "bsnes-mercury";
    rev = "ac0b6b1fe5cb9448492f4c6b3d815205eefbd142";
    hash = "sha256-DLT7Do3FWL6N63tSxeVqFW82GiCkpG5kOs82nsjCtPw=";
  };

  makeFlags = [ "PROFILE=${withProfile}" ];
  core = "bsnes-mercury-${withProfile}";
  makefile = "Makefile";

  meta = {
    description = "Fork of bsnes with HLE DSP emulation restored (${withProfile} profile)";
    homepage = "https://github.com/libretro/bsnes-mercury";
    license = lib.licenses.gpl3Only;
  };
}
