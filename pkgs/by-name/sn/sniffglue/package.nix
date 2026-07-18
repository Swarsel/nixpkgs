{
  lib,
  stdenv,
  fetchFromGitHub,
  libpcap,
  libseccomp,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sniffglue";
  version = "0.16.2";

  src = fetchFromGitHub {
    owner = "kpcyrd";
    repo = "sniffglue";
    rev = "v${finalAttrs.version}";
    hash = "sha256-i4qTqFCoQ3gXTGQ6PD4R2YhRfWztw8cd6XuZuKRlS+U=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpcap
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libseccomp
  ];

  cargoHash = "sha256-aZQ7Nq44ACAx6M3XoJZiUw9Yfm4VlJA9zBnPpgV0q4A=";

  meta = {
    description = "Secure multithreaded packet sniffer";
    homepage = "https://github.com/kpcyrd/sniffglue";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ xrelkd ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "sniffglue";
  };
})
