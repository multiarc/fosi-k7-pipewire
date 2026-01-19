-- Fosi Audio K7 DAC/Amp WirePlumber Configuration
-- Supports both UAC 1.0 (microphone + 48kHz) and UAC 2.0 (high-res up to 384kHz)

-- Ensure alsa_monitor exists
if alsa_monitor == nil then
  return
end

alsa_monitor.rules = alsa_monitor.rules or {}

-- ============================================================================
-- UAC 2.0 MODE: High Resolution Output (matched by "high speed" USB)
-- ============================================================================
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "node.name", "matches", "alsa_output.usb-Fosi_Audio_Fosi_Audio_K7*" },
      { "alsa.long_card_name", "matches", "*high speed*" },
    },
  },
  apply_properties = {
    ["audio.rate"] = 384000,
    ["audio.allowed-rates"] = "44100,48000,88200,96000,176400,192000,352800,384000",
    ["audio.format"] = "S32LE",
    -- Larger buffers for stability at high sample rates
    -- 2048 samples @ 384kHz = 5.3ms latency
    ["api.alsa.period-size"] = 2048,
    ["api.alsa.period-num"] = 3,
    ["api.alsa.headroom"] = 2048,
    -- Force larger quantum for high sample rates to prevent crackling
    ["node.latency"] = "2048/384000",
    ["api.alsa.multirate"] = true,
    ["resample.quality"] = 10,
    ["session.suspend-timeout-seconds"] = 0,
    ["node.nick"] = "Fosi Audio K7 (UAC 2.0 Hi-Res)",
  },
})

-- ============================================================================
-- UAC 1.0 MODE: Compatibility Output (matched by "full speed" USB)
-- ============================================================================
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "node.name", "matches", "alsa_output.usb-Fosi_Audio_Fosi_Audio_K7*" },
      { "alsa.long_card_name", "matches", "*full speed*" },
    },
  },
  apply_properties = {
    ["audio.rate"] = 48000,
    ["audio.allowed-rates"] = "44100,48000",
    ["audio.format"] = "S16LE",
    -- 1024 samples @ 48kHz = 21.3ms latency
    ["api.alsa.period-size"] = 1024,
    ["api.alsa.period-num"] = 2,
    ["api.alsa.headroom"] = 1024,
    ["node.latency"] = "1024/48000",
    ["api.alsa.multirate"] = false,
    ["resample.quality"] = 10,
    ["session.suspend-timeout-seconds"] = 0,
    ["node.nick"] = "Fosi Audio K7 (UAC 1.0)",
  },
})

-- ============================================================================
-- UAC 1.0 MODE: Microphone Input
-- ============================================================================
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "node.name", "matches", "alsa_input.usb-Fosi_Audio_Fosi_Audio_K7*" },
    },
  },
  apply_properties = {
    ["audio.rate"] = 48000,
    ["audio.allowed-rates"] = "44100,48000",
    ["audio.format"] = "S16LE",
    -- 1024 samples @ 48kHz = 21.3ms latency
    ["api.alsa.period-size"] = 1024,
    ["api.alsa.period-num"] = 2,
    ["api.alsa.headroom"] = 1024,
    ["node.latency"] = "1024/48000",
    ["resample.quality"] = 10,
    ["session.suspend-timeout-seconds"] = 0,
    ["node.nick"] = "Fosi Audio K7 Mic",
  },
})

-- ============================================================================
-- Device-level settings: UAC 2.0 Mode (high speed) - Output only
-- ============================================================================
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "device.name", "matches", "alsa_card.usb-Fosi_Audio_Fosi_Audio_K7*" },
      { "api.alsa.card.longname", "matches", "*high speed*" },
    },
  },
  apply_properties = {
    ["device.nick"] = "Fosi Audio K7 DAC/Amp (UAC 2.0)",
    -- UAC 2.0: Use digital stereo output only (no mic available)
    ["device.profile"] = "output:iec958-stereo",
  },
})

-- ============================================================================
-- Device-level settings: UAC 1.0 Mode (full speed) - Output + Microphone Input
-- ============================================================================
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "device.name", "matches", "alsa_card.usb-Fosi_Audio_Fosi_Audio_K7*" },
      { "api.alsa.card.longname", "matches", "*full speed*" },
    },
  },
  apply_properties = {
    ["device.nick"] = "Fosi Audio K7 DAC/Amp (UAC 1.0)",
    -- UAC 1.0: Use digital output + analog input (microphone)
    ["device.profile"] = "output:iec958-stereo+input:analog-stereo",
  },
})
