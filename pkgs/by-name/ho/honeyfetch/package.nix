{
  lib,
  fetchFromGitLab,
  libdrm,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "honeyfetch";
  version = "1.5.0";

  src = fetchFromGitLab {
    owner = "ahoneybun";
    repo = "honeyfetch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lFp7L3tcqZ1jAL7V7tfUJDPKO2WCvMekUx+p12fNlcM=";
  };

  buildInputs = [ libdrm ];
  cargoHash = "sha256-u+OF4ali7GoHktY8jihgqUQ+4kFuKQNbiaRUdOJrQfA=";

  meta = {
    description = "Classy neofetch but in Rust";
    homepage = "https://gitlab.com/ahoneybun/honeyfetch";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ ahoneybun ];
    platforms = lib.platforms.linux;
  };
})
