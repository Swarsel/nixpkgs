{
  makeBinaryWrapper,
  makeSetupHook,
  writeScript,
  xbitmaps,
}:

makeSetupHook
  {
    propagatedBuildInputs = [ makeBinaryWrapper ];
    name = "wrapWithXFileSearchPathHook";
  }
  (
    writeScript "wrapWithXFileSearchPathHook.sh" ''
      wrapWithXFileSearchPath() {
        paths=(
          "$out/share/X11/%T/%N"
          "$out/include/X11/%T/%N"
          "${xbitmaps}/include/X11/%T/%N"
        )
        for exe in $out/bin/*; do
          wrapProgram "$exe" \
            --suffix XFILESEARCHPATH : $(IFS=:; echo "''${paths[*]}")
        done
      }
      postInstallHooks+=(wrapWithXFileSearchPath)
    ''
  )
