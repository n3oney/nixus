{
  lib,
  config,
  ...
}: let
  c = base: "#${config.colors.colorScheme.palette.${base}}";
in {
  config = lib.mkIf config.display.noctalia.enable {
    hm.programs.noctalia.customPalettes.nixus.dark = {
      mPrimary = c "accent";
      mOnPrimary = c "base00";
      mSecondary = c "base0C";
      mOnSecondary = c "base00";
      mTertiary = c "base0E";
      mOnTertiary = c "base00";
      mError = c "base08";
      mOnError = c "base00";
      mSurface = c "base00";
      mOnSurface = c "base05";
      mSurfaceVariant = c "base02";
      mOnSurfaceVariant = c "base04";
      mOutline = c "base03";
      mShadow = c "base01";
      mHover = c "accent";
      mOnHover = c "base00";

      # v5 rejects any palette mode missing a terminal block.
      terminal = {
        background = c "base00";
        foreground = c "base05";
        cursor = c "base05";
        cursorText = c "base00";
        selectionBg = c "base02";
        selectionFg = c "base05";
        normal = {
          black = c "base00";
          red = c "base08";
          green = c "base0B";
          yellow = c "base0A";
          blue = c "base0D";
          magenta = c "base0E";
          cyan = c "base0C";
          white = c "base05";
        };
        bright = {
          black = c "base03";
          red = c "base08";
          green = c "base0B";
          yellow = c "base0A";
          blue = c "base0D";
          magenta = c "base0E";
          cyan = c "base0C";
          white = c "base07";
        };
      };
    };
  };
}
