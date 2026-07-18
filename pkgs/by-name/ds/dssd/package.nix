{
  lib,
  fetchFromGitHub,
  dbus,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dssd";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "ylxdzsw";
    repo = "dssd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gAV4gwrfvYfc2f1tDY/cNOFMrQzrzHSmEFsKg7ke/6c=";
  };

  postPatch = ''
    substituteInPlace dssd.service org.freedesktop.secrets.service \
      --replace-fail /usr/bin/dssd $out/bin/dssd
  '';

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];
  cargoHash = "sha256-yX2/2TW3FNbqwzR6+5yP26E2Eps0bTJgJJrDIQG2KQU=";

  postInstall = ''
    install dssd.service -Dt $out/lib/systemd/user/
    install org.freedesktop.secrets.service -Dt $out/share/dbus-1/system-services/
  '';

  __structuredAttrs = true;

  meta = {
    description = "Dead Simple Secret Daemon";
    homepage = "https://github.com/ylxdzsw/dssd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phanirithvij ];
    platforms = lib.platforms.linux;
    mainProgram = "dssd";
  };
})
