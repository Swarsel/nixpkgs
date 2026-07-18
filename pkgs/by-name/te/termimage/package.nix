{
  lib,
  fetchCrate,
  installShellFiles,
  ronn,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "termimage";
  version = "1.2.1";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-1FOPe466GqQfiIpsQT9DJn+FupI2vy9b4+7p31ceY6M=";
  };

  nativeBuildInputs = [
    installShellFiles
    ronn
  ];

  cargoHash = "sha256-SIPak7tl/fIH6WzvAl8bjhclZqQ6imC/zdxCnBnEsbk=";
  env.RUSTFLAGS = "-Adangerous_implicit_autorefs";

  postInstall = ''
    ronn --roff --organization="termimage developers" termimage.md
    installManPage termimage.1
  '';

  meta = {
    description = "Display images in your terminal";
    homepage = "https://github.com/nabijaczleweli/termimage";
    changelog = "https://github.com/nabijaczleweli/termimage/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "termimage";
  };
})
