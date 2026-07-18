{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "arduino-language-server";
  version = "0.7.7";

  src = fetchFromGitHub {
    owner = "arduino";
    repo = "arduino-language-server";
    tag = finalAttrs.version;
    hash = "sha256-twTbJ5SFbL4AIX+ffB0LdOYXUxh4SzmZguJSRdEo1lQ=";
  };

  vendorHash = "sha256-wXArVPzYmuiivx+8M86rrvfKsvCMtkN3WgXQByr5fC4=";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/arduino/arduino-language-server/version.versionString=${finalAttrs.version}"
    "-X github.com/arduino/arduino-language-server/version.commit=unknown"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "-extldflags '-static'"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Arduino Language Server based on Clangd to Arduino code autocompletion";
    homepage = "https://github.com/arduino/arduino-language-server";
    changelog = "https://github.com/arduino/arduino-language-server/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ BattleCh1cken ];
    mainProgram = "arduino-language-server";
  };
})
