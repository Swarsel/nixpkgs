{
  makeSetupHook,
}:
makeSetupHook {
  __structuredAttrs = true;
  # Shouldn't need to propagate anything because for this to do anything useful,
  # the config hook must also be used.
  name = "pnpm-build-hook";
} ./pnpm-build-hook.sh
