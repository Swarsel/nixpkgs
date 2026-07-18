{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxfixes,
  libxkbcommon,
  pkg-config,
  vulkan-headers,
  wayland,
}:

buildGoModule (finalAttrs: {
  pname = "gotraceui";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "dominikh";
    repo = "gotraceui";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-Rforuh9YlTv/mTpQm0+BaY+Ssc4DAiDCzVkIerP5Uz0=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-dxsVMjyKkRG4Q6mONlJAohWJ8YTu8KN7ynPVycJhcs8=";
      name = "switch-to-gio-fork.patch";
      url = "https://github.com/dominikh/gotraceui/commit/00289f5f4c1da3e13babd2389e533b069cd18e3c.diff";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    vulkan-headers
    libxkbcommon
    wayland
    libx11
    libxcb
    libxcursor
    libxfixes
    libGL
  ];

  vendorHash = "sha256-9rzcSxlOuQC5bt1kZuRX7CTQaDHKrtGRpMNLrOHTjJk=";

  postInstall = ''
    cp -r share $out/
  '';

  ldflags = [ "-X gioui.org/app.ID=co.honnef.Gotraceui" ];
  subPackages = [ "cmd/gotraceui" ];

  meta = {
    description = "Efficient frontend for Go execution traces";
    homepage = "https://github.com/dominikh/gotraceui";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dominikh ];
    platforms = lib.platforms.linux;
    mainProgram = "gotraceui";
  };
})
