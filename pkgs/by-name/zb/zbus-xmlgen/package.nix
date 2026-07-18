{
  lib,
  fetchCrate,
  makeBinaryWrapper,
  rustPlatform,
  rustfmt,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zbus_xmlgen";
  version = "5.4.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-qfn1DZjRrOStoEHt5HOekW9N2K6S0M/w+iWZ42OPaME=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  cargoHash = "sha256-ECxn6C6Qrv7xPp+MJR9IIJAEO+Xp83udy9Zv/QlUCrE=";
  nativeCheckInputs = [ rustfmt ];

  postInstall = ''
    wrapProgram $out/bin/zbus-xmlgen \
        --prefix PATH : ${lib.makeBinPath [ rustfmt ]}
  '';

  meta = {
    description = "D-Bus XML interface Rust code generator";
    homepage = "https://crates.io/crates/zbus_xmlgen";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qyliss ];
    mainProgram = "zbus-xmlgen";
  };
})
