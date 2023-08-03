{
  config,
  lib,
  pkgs,
  ...
}: let
  configFile = pkgs.writeText "shairport-sync.conf" ''
     general =
     {
     	name = "max"; // This means "Hostname" -- see below. This is the name the service will advertise to iTunes.
     //		The default is "Hostname" -- i.e. the machine's hostname with the first letter capitalised (ASCII only.)
     //		You can use the following substitutions:
     //				%h for the hostname,
     //				%H for the Hostname (i.e. with first letter capitalised (ASCII only)),
     //				%v for the version number, e.g. 3.0 and
     //				%V for the full version string, e.g. 3.3-OpenSSL-Avahi-ALSA-soxr-metadata-sysconfdir:/etc
     //		Overall length can not exceed 50 characters. Example: "Shairport Sync %v on %H".
     //	password = "secret"; // (AirPlay 1 only) leave this commented out if you don't want to require a password
     //	interpolation = "auto"; // aka "stuffing". Default is "auto". Alternatives are "basic" or "soxr". Choose "soxr" only if you have a reasonably fast processor and Shairport Sync has been built with "soxr" support.
     	output_backend = "pa"; // Run "shairport-sync -h" to get a list of all output_backends, e.g. "alsa", "pipe", "stdout". The default is the first one.
     //	mdns_backend = "avahi"; // Run "shairport-sync -h" to get a list of all mdns_backends. The default is the first one.
     //	interface = "name"; // Use this advanced setting to specify the interface on which Shairport Sync should provide its service. Leave it commented out to get the default, which is to select the interface(s) automatically.
     //	port = 7000; // Listen for service requests on this port. 5000 for AirPlay 1, 7000 for AirPlay 2
     //	udp_port_base = 6001; // (AirPlay 1 only) start allocating UDP ports from this port number when needed
     //	udp_port_range = 10; // (AirPlay 1 only) look for free ports in this number of places, starting at the UDP port base. Allow at least 10, though only three are needed in a steady state.
     //	airplay_device_id_offset = 0; // (AirPlay 2 only) add this to the default airplay_device_id calculated from one of the device's MAC address
     //	airplay_device_id = 0xDEDBEEL; // (AirPlay 2 only) use this as the airplay_device_id e.g. 0xDCA632D4E8F3L -- remember the "L" at the end as it's a 64-bit quantity!
     //	regtype = "<string>"; // Use this advanced setting to set the service type and transport to be advertised by Zeroconf/Bonjour. Default is "_raop._tcp" for AirPlay 1, "_airplay._tcp" for AirPlay 2.

     //	drift_tolerance_in_seconds = 0.002; // allow a timing error of this number of seconds of drift away from exact synchronisation before attempting to correct it
     //	resync_threshold_in_seconds = 0.050; // a synchronisation error greater than this number of seconds will cause resynchronisation; 0 disables it
     //	resync_recovery_time_in_seconds = 0.100; // allow this extra time to recover after a late resync. Increase the value, possibly to 0.5, in a virtual machine.
     //	playback_mode = "stereo"; // This can be "stereo", "mono", "reverse stereo", "both left" or "both right". Default is "stereo".
     //	alac_decoder = "hammerton"; // This can be "hammerton" or "apple". This advanced setting allows you to choose
     //		the original Shairport decoder by David Hammerton or the Apple Lossless Audio Codec (ALAC) decoder written by Apple.
     //		If you build Shairport Sync with the flag --with-apple-alac, the Apple ALAC decoder will be chosen by default.

     //	ignore_volume_control = "no"; // set this to "yes" if you want the volume to be at 100% no matter what the source's volume control is set to.
     //	volume_range_db = 60 ; // use this advanced setting to set the range, in dB, you want between the maximum volume and the minimum volume. Range is 30 to 150 dB. Leave it commented out to use mixer's native range.
     //	volume_max_db = 0.0 ; // use this advanced setting, which must have a decimal point in it, to set the maximum volume, in dB, you wish to use.
     //		The setting is for the hardware mixer, if chosen, or the software mixer otherwise. The value must be in the mixer's range (0.0 to -96.2 for the software mixer).
     //		Leave it commented out to use mixer's maximum volume.
     //	volume_control_profile = "standard" ; // use this advanced setting to specify how the airplay volume is transferred to the mixer volume.
     //		"standard" makes the volume change more quickly at lower volumes and slower at higher volumes.
     //		"flat" makes the volume change at the same rate at all volumes.
     //	volume_control_combined_hardware_priority = "no"; // when extending the volume range by combining the built-in software attenuator with the hardware mixer attenuator, set this to "yes" to reduce volume by using the hardware mixer first, then the built-in software attenuator.

     //	default_airplay_volume = -24.0; // this is the suggested volume after a reset or after the high_volume_threshold has been exceed and the high_volume_idle_timeout_in_minutes has passed

     //	The following settings are for dealing with potentially surprising high ("very loud") volume levels.
     //	When a new play session starts, it usually requests a suggested volume level from Shairport Sync. This is normally the volume level of the last session.
     //	This can cause unpleasant surprises if the last session was (a) very loud and (b) a long time ago.
     //	Thus, the user could be unpleasantly surprised by the volume level of the new session.

     //	To deal with this, when the last session volume is "very loud", the following two settings will lower the suggested volume after a period of idleness:

     //	high_threshold_airplay_volume = -16.0; // airplay volume greater or equal to this is "very loud"
     //	high_volume_idle_timeout_in_minutes = 0; // if the current volume is "very loud" and the device is not playing for more than this time, suggest the default volume for new connections instead of the current volume.
     //		Note 1: This timeout is set to 0 by default to disable this feature. Set it to some positive number, e.g. 180 to activate the feature.
     //		Note 2: Not all applications use the suggested volume: MacOS Music and Mac OS System Sounds use their own settings.

     //	run_this_when_volume_is_set = "/full/path/to/application/and/args"; //	Run the specified application whenever the volume control is set or changed.
     //		The desired AirPlay volume is appended to the end of the command line – leave a space if you want it treated as an extra argument.
     //		AirPlay volume goes from 0.0 to -30.0 and -144.0 means "mute".

     //	audio_backend_latency_offset_in_seconds = 0.0; // This is added to the latency requested by the player to delay or advance the output by a fixed amount.
     //		Use it, for example, to compensate for a fixed delay in the audio back end.
     //		E.g. if the output device, e.g. a soundbar, takes 100 ms to process audio, set this to -0.1 to deliver the audio
     //		to the output device 100 ms early, allowing it time to process the audio and output it perfectly in sync.
     //	audio_backend_buffer_desired_length_in_seconds = 0.2; // If set too small, buffer underflow occurs on low-powered machines.
     //		Too long and the response time to volume changes becomes annoying.
     //		Default is 0.2 seconds in the alsa backend, 0.35 seconds in the pa backend and 1.0 seconds otherwise.
     //	audio_backend_buffer_interpolation_threshold_in_seconds = 0.075; // Advanced feature. If the buffer size drops below this, stop using time-consuming interpolation like soxr to avoid dropouts due to underrun.
     //	audio_backend_silent_lead_in_time = "auto"; // This optional advanced setting, either "auto" or a positive number, sets the length of the period of silence that precedes the start of the audio.
     //		The default is "auto" -- the silent lead-in starts as soon as the player starts sending packets.
     //		Values greater than the latency are ignored. Values that are too low will affect initial synchronisation.

     //	dbus_service_bus = "system"; // The Shairport Sync dbus interface, if selected at compilation, will appear
     //		as "org.gnome.ShairportSync" on the whichever bus you specify here: "system" (default) or "session".
     //	mpris_service_bus = "system"; // The Shairport Sync mpris interface, if selected at compilation, will appear
     //		as "org.gnome.ShairportSync" on the whichever bus you specify here: "system" (default) or "session".

     //	resend_control_first_check_time = 0.10; // Use this optional advanced setting to set the wait time in seconds before deciding a packet is missing.
     //	resend_control_check_interval_time = 0.25; //  Use this optional advanced setting to set the time in seconds between requests for a missing packet.
     //	resend_control_last_check_time = 0.10; // Use this optional advanced setting to set the latest time, in seconds, by which the last check should be done before the estimated time of a missing packet's transfer to the output buffer.
     //	missing_port_dacp_scan_interval_seconds = 2.0; // Use this optional advanced setting to set the time interval between scans for a DACP port number if no port number has been provided by the player for remote control commands
     };

     // Advanced parameters for controlling how Shairport Sync stays active and how it runs a session
     sessioncontrol =
     {
     //	"active" state starts when play begins and ends when the active_state_timeout has elapsed after play ends, unless another play session starts before the timeout has fully elapsed.
     //	run_this_before_entering_active_state = "/full/path/to/application and args"; // make sure the application has executable permission. If it's a script, include the shebang (#!/bin/...) on the first line
     //	run_this_after_exiting_active_state = "/full/path/to/application and args"; // make sure the application has executable permission. If it's a script, include the shebang (#!/bin/...) on the first line
     //	active_state_timeout = 10.0; // wait for this number of seconds after play ends before leaving the active state, unless another play session begins.

     //	run_this_before_play_begins = "/full/path/to/application and args"; // make sure the application has executable permission. If it's a script, include the shebang (#!/bin/...) on the first line
     //	run_this_after_play_ends = "/full/path/to/application and args"; // make sure the application has executable permission. If it's a script, include the shebang (#!/bin/...) on the first line

     //	run_this_if_an_unfixable_error_is_detected = "/full/path/to/application and args"; // if a problem occurs that can't be cleared by Shairport Sync itself, hook a program on here to deal with it.
     //	  An error code-string is passed as the last argument.
     //	  Many of these "unfixable" problems are caused by malfunctioning output devices, and sometimes it is necessary to restart the whole device to clear the problem.
     //	  You could hook on a program to do this automatically, but beware -- the device may then power off and restart without warning!
     //	wait_for_completion = "no"; // set to "yes" to get Shairport Sync to wait until the "run_this..." applications have terminated before continuing

     //	allow_session_interruption = "no"; // set to "yes" to allow another device to interrupt Shairport Sync while it's playing from an existing audio source
     //	session_timeout = 120; // wait for this number of seconds after a source disappears before terminating the session and becoming available again.
     };

     // Parameters for the "pa" PulseAudio  backend.
     // For this section to be operative, Shairport Sync must be built with the following configuration flag:
     // --with-pa
     pa =
     {
     	server = "127.0.0.1"; // Set this to override the default pulseaudio server that should be used.
     	sink = "alsa_output.usb-Logitech_PRO_X_000000000000-00.analog-stereo"; // Set this to override the default pulseaudio sink that should be used. (Untested)
     //	application_name = "Shairport Sync"; //Set this to the name that should appear in the Sounds "Applications" tab when Shairport Sync is active.
     };

     //////////////////////////////////////////
     // This loudness filter is used to compensate for human ear non linearity.
     // When the volume decreases, our ears loose more sentisitivity in the low range frequencies than in the mid range ones.
     // This filter aims at compensating for this loss, applying a variable gain to low frequencies depending on the volume.
     // More info can be found here: https://en.wikipedia.org/wiki/Equal-loudness_contour
     // For this filter to work properly, you should disable (or set to a fix value) all other volume control and only let shairport-sync control your volume.
     // The setting "loudness_reference_volume_db" should be set at the volume reported by shairport-sync when listening to music at a normal listening volume.
     //////////////////////////////////////////
     //
     //	loudness = "no";                      // Set this to "yes" to activate the loudness filter
     //	loudness_reference_volume_db = -20.0; // Above this level the filter will have no effect anymore. Below this level it will gradually boost the low frequencies.

     // How to deal with metadata, including artwork
     // For this section to be operative, Shairport Sync must be built with at one (or more) of the following configuration flags:
     // --with-metadata, --with-dbus-interface, --with-mpris-interface or --with-mqtt-client.
     // In those cases, "enabled" and "include_cover_art" will both be "yes" by default
     metadata =
     {
     //	enabled = "yes"; // set this to yes to get Shairport Sync to solicit metadata from the source and to pass it on via a pipe
     //	include_cover_art = "yes"; // set to "yes" to get Shairport Sync to solicit cover art from the source and pass it via the pipe. You must also set "enabled" to "yes".
     //	cover_art_cache_directory = "/tmp/shairport-sync/.cache/coverart"; // artwork will be  stored in this directory if the dbus or MPRIS interfaces are enabled or if the MQTT client is in use. Set it to "" to prevent caching, which may be useful on some systems
     //	pipe_name = "/tmp/shairport-sync-metadata";
     //	pipe_timeout = 5000; // wait for this number of milliseconds for a blocked pipe to unblock before giving up
     //	progress_interval = 0.0; // if non-zero, progress 'phbt' messages will be sent at the interval specified in seconds. A 'phb0' message will also be sent when the first audio frame of a play session is about to be played.
     //		Each message consists of the RTPtime of a a frame of audio and the exact system time when it is to be played. The system time, in nanoseconds, is based the CLOCK_MONOTONIC_RAW of the machine -- if available -- or CLOCK_MONOTONIC otherwise.
     //		Messages are sent when the frame is placed in the output device's buffer, thus, they will be _approximately_ 'audio_backend_buffer_desired_length_in_seconds' (default 0.2 seconds) ahead of time.
     //	socket_address = "226.0.0.1"; // if set to a host name or IP address, UDP packets containing metadata will be sent to this address. May be a multicast address. "socket-port" must be non-zero and "enabled" must be set to yes"
     //	socket_port = 5555; // if socket_address is set, the port to send UDP packets to
     //	socket_msglength = 65000; // the maximum packet size for any UDP metadata. This will be clipped to be between 500 or 65000. The default is 500.
     };

    // Diagnostic settings. These are for diagnostic and debugging only. Normally you should leave them commented out
     diagnostics =
     {
     //	disable_resend_requests = "no"; // set this to yes to stop Shairport Sync from requesting the retransmission of missing packets. Default is "no".
     //	log_output_to = "syslog"; // set this to "syslog" (default), "stderr" or "stdout" or a file or pipe path to specify were all logs, statistics and diagnostic messages are written to. If there's anything wrong with the file spec, output will be to "stderr".
     //	statistics = "no"; // set to "yes" to print statistics in the log
     //	log_verbosity = 0; // "0" means no debug verbosity, "3" is most verbose.
     //	log_show_file_and_line = "yes"; // set this to yes if you want the file and line number of the message source in the log file
     //	log_show_time_since_startup = "no"; // set this to yes if you want the time since startup in the debug message -- seconds down to nanoseconds
     //	log_show_time_since_last_message = "yes"; // set this to yes if you want the time since the last debug message in the debug message -- seconds down to nanoseconds
     //	drop_this_fraction_of_audio_packets = 0.0; // use this to simulate a noisy network where this fraction of UDP packets are lost in transmission. E.g. a value of 0.001 would mean an average of 0.1% of packets are lost, which is actually quite a high figure.
     //	retain_cover_art = "no"; // artwork is deleted when its corresponding track has been played. Set this to "yes" to retain all artwork permanently. Warning -- your directory might fill up.
     };
  '';
in {
  options.services.shairport-sync.enable = lib.mkEnableOption "shairport-sync";

  config.os = lib.mkIf config.services.shairport-sync.enable {
    services.shairport-sync = {
      enable = true;
      openFirewall = true;
      arguments = "-v -o pa -c ${configFile}";
    };

    users.users.shairport.extraGroups = ["pulse-access"];

    systemd.services.shairport-sync = {
      after = ["pulseaudio.service"];
      requires = ["pulseaudio.service"];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
