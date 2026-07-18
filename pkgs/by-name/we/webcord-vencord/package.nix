{
  lib,
  # allow overriding electron
  electron_42,
  replaceVars,
  vencord-web-extension,
  webcord,
}:

# nixpkgs-update: no auto update
(webcord.override { inherit electron_42; }).overrideAttrs (old: {
  pname = "webcord-vencord";

  patches = (old.patches or [ ]) ++ [
    (replaceVars ./add-extension.patch {
      vencord = vencord-web-extension;
    })
  ];

  meta = {
    inherit (old.meta) license mainProgram platforms;
    description = "Webcord with Vencord web extension";
    homepage = "https://github.com/SpacingBat3/WebCord";

    maintainers = with lib.maintainers; [
      FlafyDev
      NotAShelf
    ];
  };
})
