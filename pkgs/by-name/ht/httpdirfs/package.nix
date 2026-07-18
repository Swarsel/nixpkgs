{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  expat,
  fuse3,
  gumbo,
  help2man,
  libuuid,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "httpdirfs";
  version = "1.2.10";

  src = fetchFromGitHub {
    owner = "fangfufu";
    repo = "httpdirfs";
    tag = finalAttrs.version;
    hash = "sha256-dfMavLEBXry1cW4o2yQjuvBbYIvct1GXzACj+9Hh4wE=";
  };

  nativeBuildInputs = [
    help2man
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    curl
    expat
    fuse3
    gumbo
    libuuid
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=attribute-warning"
    "-Wno-error=pedantic"
  ];

  passthru = {
    tests.version = testers.testVersion {
      command = "${lib.getExe finalAttrs.finalPackage} --version";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "FUSE filesystem for HTTP directory listings";
    homepage = "https://github.com/fangfufu/httpdirfs";
    changelog = "https://github.com/fangfufu/httpdirfs/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      schnusch
      anthonyroussel
    ];

    platforms = lib.platforms.linux;
    mainProgram = "httpdirfs";
  };
})
