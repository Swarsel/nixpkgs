{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
}:

buildGoModule {
  pname = "zztgo";
  version = "0-unstable-2020-05-29";

  src = fetchFromGitHub {
    owner = "benhoyt";
    repo = "zztgo";
    rev = "9edb1452d887852c5c68cae0a91a6227cd4ef7a9";
    hash = "sha256-Wz9xAcsT27scuR78X6+17l0RExpmh0uTQUOcQ9lHIkI=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-0hOXo7Ww34yI5yrz4CDMuFZjPj9CqtmWxQoc9aEBFOs=";

  postInstall = ''
    install -Dm644 TOWN.ZZT $out/share/zztgo/TOWN.ZZT
    install -Dm644 zzt.terminal $out/share/zztgo/zzt.terminal

    wrapProgram $out/bin/zztgo \
      --chdir $out/share/zztgo
  '';

  __structuredAttrs = true;

  meta = {
    description = "Port of ZZT to Go";
    homepage = "https://github.com/benhoyt/zztgo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ castorNova2 ];
    platforms = lib.platforms.unix;
    mainProgram = "zztgo";
  };
}
