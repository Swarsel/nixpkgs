{
  lib,
  fetchFromGitHub,
  buildGoModule,
  iptables,
}:

buildGoModule (finalAttrs: {
  pname = "gerbil";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "fosrl";
    repo = "gerbil";
    tag = finalAttrs.version;
    hash = "sha256-NlwP2A1SGEDgoLubLs2HHnaOPUu5L84I1kJAbXyja7Q=";
  };

  # patch out the /usr/sbin/iptables
  postPatch = ''
    substituteInPlace main.go \
      --replace-fail '/usr/sbin/iptables' '${lib.getExe iptables}'
  '';

  vendorHash = "sha256-S5olgsmX0uZR9P/u/8Rf3lzRCSIwPDcmlvSzJhhJM3w=";

  meta = {
    description = "Simple WireGuard interface management server";
    homepage = "https://github.com/fosrl/gerbil";
    changelog = "https://github.com/fosrl/gerbil/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      jackr
      water-sucks
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gerbil";
  };
})
