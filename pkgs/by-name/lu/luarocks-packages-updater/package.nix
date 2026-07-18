{
  lib,
  lua5_1,
  lua5_2,
  lua5_3,
  lua5_4,
  luajit,
  luarocks-nix,
  makeWrapper,
  nix,
  nix-prefetch-scripts,
  nixfmt,
  python3Packages,
}:
let

  path = lib.makeBinPath [
    nix
    nixfmt
    nix-prefetch-scripts
    luarocks-nix
    lua5_1
    lua5_2
    lua5_3
    lua5_4
    luajit
  ];

  attrs = fromTOML (builtins.readFile ./pyproject.toml);
  pname = attrs.project.name;
  inherit (attrs.project) version;
in

python3Packages.buildPythonApplication {
  inherit pname version;
  src = lib.cleanSource ./.;

  postFixup = ''
    wrapProgram $out/bin/luarocks-packages-updater \
     --prefix PATH : "${path}"
  '';

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.nixpkgs-plugin-update
  ];

  pyproject = true;

  shellHook = ''
    export PATH="${path}:$PATH"
  '';

  meta = {
    inherit (attrs.project) description;
    homepage = attrs.project.urls.Homepage;
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ teto ];
    mainProgram = "luarocks-packages-updater";
  };
}
