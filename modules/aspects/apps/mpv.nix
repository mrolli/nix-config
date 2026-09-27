# Install and configure mpv
# https://nix-community.github.io/home-manager/options/home-manager/programs/mpv.html
# https://mpv.io/manual/
{ ... }:
{
  den.aspects.mpv.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.mpv ];

      xdg.configFile."mpv/mpv.conf".text = ''
        # Don't allow new windows to be larger than the screen.
        autofit-larger=100%x100%
        autofit-smaller=1000x1000
        #ytdl-raw-options="cookies-from-browser=Safari"
        # Enable hardware decoding if available, =yes is implied.
        hwdec

        # [secondary-screen]
        # screen=1
        #
        [no-video]
        no-video
      '';

      xdg.configFile."mpv/input.conf".text = ''
        Alt+3 set window-scale 3.0
        Alt+4 set window-scale 4.0
        Alt+5 set window-scale 5.0
      '';
    };
}
