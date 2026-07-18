{
  lib,
  stdenv,
  fetchFromGitHub,
  cddiscid,
  cdparanoia,
  makeWrapper,
  ruby,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rubyripper";
  version = "0.8.0rc3";

  src = fetchFromGitHub {
    owner = "bleskodev";
    repo = "rubyripper";
    rev = "v${finalAttrs.version}";
    sha256 = "1qfwv8bgc9pyfh3d40bvyr9n7sjc2na61481693wwww640lm0f9f";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    cddiscid
    cdparanoia
    ruby
  ];

  configureFlags = [ "--enable-cli" ];
  preConfigure = "patchShebangs .";

  postInstall = ''
    cp -r share $out/
  '';

  postFixup = ''
    wrapProgram $out/bin/rrip_cli \
      --prefix PATH : ${
        lib.makeBinPath [
          cddiscid
          cdparanoia
          ruby
        ]
      }
  '';

  meta = {
    description = "High quality CD audio ripper";
    homepage = "https://github.com/bleskodev/rubyripper";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "rrip_cli";
  };
})
