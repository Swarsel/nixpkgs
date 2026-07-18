{
  lib,
  dbus,
  fetchCrate,
  installShellFiles,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "citron";
  version = "0.15.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-6wJ4UfiwpV9zFuBR8SYj6eBiRqQitFs7wRe5R51Z3SA=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [ dbus ];
  cargoHash = "sha256-HEDkNzNCXKmBsI5fL8+UK4SHrU9eLde6Vfh4XhSrK+A=";

  postInstall = ''
    installManPage doc/citron.1
  '';

  meta = {
    description = "System data via on-demand notifications";
    homepage = "https://git.sr.ht/~grtcdr/citron";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vuimuich ];
    platforms = lib.platforms.linux;
    mainProgram = "citron";
  };
})
