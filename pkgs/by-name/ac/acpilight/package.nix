{
  lib,
  stdenv,
  coreutils,
  fetchgit,
  python3,
  udevCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "acpilight";
  version = "1.2";

  src = fetchgit {
    url = "https://gitlab.com/wavexx/acpilight.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PNjW/04hndcdmsY1ej1TriUblPogsm2ounObbrodGeQ=";
  };

  nativeBuildInputs = [
    udevCheckHook
  ];

  buildInputs = [ finalAttrs.pyenv ];
  makeFlags = [ "DESTDIR=$(out) prefix=" ];

  postConfigure = ''
    substituteInPlace 90-backlight.rules --replace-fail /bin ${coreutils}/bin
    substituteInPlace Makefile --replace-fail udevadm true
  '';

  doInstallCheck = true;

  pyenv = python3.withPackages (
    pythonPackages: with pythonPackages; [
      configargparse
    ]
  );

  meta = {
    description = "ACPI backlight control";
    homepage = "https://gitlab.com/wavexx/acpilight";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ smakarov ];
    platforms = lib.platforms.linux;
    mainProgram = "xbacklight";
  };
})
