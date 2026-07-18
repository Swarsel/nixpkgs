{
  lib,
  stdenv,
  curl,
  fetchFromCodeberg,
  nix-update-script,
  openssl,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snac2";
  version = "2.92";

  src = fetchFromCodeberg {
    owner = "grunfink";
    repo = "snac2";
    tag = finalAttrs.version;
    hash = "sha256-psZtNrw6EjN52Hpl3aePnPQ2F/WoPEc5JQbqFknUeQk=";
  };

  buildInputs = [
    curl
    openssl
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [
      "-Dst_mtim=st_mtimespec"
      "-Dst_ctim=st_ctimespec"
    ]
  );

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/snac";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple, minimalistic ActivityPub instance (2.x, C)";
    homepage = "https://codeberg.org/grunfink/snac2";
    changelog = "https://codeberg.org/grunfink/snac2/src/tag/${finalAttrs.version}/RELEASE_NOTES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
    mainProgram = "snac";
  };
})
