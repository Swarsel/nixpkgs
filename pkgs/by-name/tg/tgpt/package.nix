{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libx11,
}:

buildGoModule (finalAttrs: {
  pname = "tgpt";
  version = "2.11.1";

  src = fetchFromGitHub {
    owner = "aandrew-me";
    repo = "tgpt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FsLJXJBPg9Lz5iOcoIMkcs8zH4hkSWKjlIU0MLjL4k0=";
  };

  buildInputs = [ libx11 ];
  vendorHash = "sha256-MV86fp6684lBhFrqYXJCf1OguftncVVb/1wEPgvaOYc=";

  preCheck = ''
    # Remove test which need network access
    rm src/providers/koboldai/koboldai_test.go
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "ChatGPT in terminal without needing API keys";
    homepage = "https://github.com/aandrew-me/tgpt";
    changelog = "https://github.com/aandrew-me/tgpt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "tgpt";
  };
})
