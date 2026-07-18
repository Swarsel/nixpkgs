{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  openssh,
}:

buildGoModule (finalAttrs: {
  pname = "diskrsync";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "dop251";
    repo = "diskrsync";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-hM70WD+M3jwze0IG84WTFf1caOUk2s9DQ7pR+KNIt1M=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-lJaM/sC5/qmmo7Zu7nGR6ZdXa1qw4SuVxawQ+d/m+Aw=";

  preFixup = ''
    wrapProgram "$out/bin/diskrsync" --argv0 diskrsync --prefix PATH : ${openssh}/bin
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Rsync for block devices and disk images";
    homepage = "https://github.com/dop251/diskrsync";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
    mainProgram = "diskrsync";
  };
})
