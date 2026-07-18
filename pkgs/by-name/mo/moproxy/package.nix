{
  lib,
  fetchurl,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moproxy";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "sorz";
    repo = "moproxy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Rqno+cg44IWBJbKWUP6BnxzwCjuNhFo9nBF6u2jlyA4=";
  };

  cargoHash = "sha256-SJHsXck2f9xJZ4GmOkISjdfqxlF4LCAH9WYjqSqFFkE=";

  preBuild =
    let
      webBundle = fetchurl {
        hash = "sha256-bLC76LnTWR2/xnDcZtX/t0OUmP7vdI/o3TCRzG9eH/g=";
        url = "https://github.com/sorz/moproxy-web/releases/download/v0.1.8/build.zip";
      };
    in
    ''
      # build script try to download from network
      sed -i '15s/.*/let zip_path = PathBuf::from("${
        lib.escape [ "/" ] (toString webBundle)
      }");/' build.rs
    '';

  meta = {
    description = "Transparent TCP to SOCKSv5/HTTP proxy on Linux written in Rust";
    homepage = "https://github.com/sorz/moproxy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oluceps ];
    platforms = lib.platforms.linux;
    mainProgram = "moproxy";
  };
})
