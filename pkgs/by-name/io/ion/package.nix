{
  lib,
  fetchFromGitLab,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "ion";
  version = "unstable-2024-09-20";

  src = fetchFromGitLab {
    owner = "redox-os";
    repo = "ion";
    rev = "8acd140eeec76cd5efbd36f9ea8425763200a76b";
    hash = "sha256-jiJ5XW7S6/pVEOPYJKurolLI3UrOyuaEP/cqm1a0rIU=";
    domain = "gitlab.redox-os.org";
  };

  patches = [
    # remove git revision from the build script to fix build
    ./build-script.patch
  ];

  cargoHash = "sha256-Gqa2aA8jr6SZexa6EejYHv/aEYcm51qvEJSUm4m1AVc=";

  passthru = {
    shellPath = "/bin/ion";
  };

  meta = {
    description = "Modern system shell with simple (and powerful) syntax";
    homepage = "https://gitlab.redox-os.org/redox-os/ion";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dywedir ];
    platforms = lib.platforms.unix;
    mainProgram = "ion";
  };
}
