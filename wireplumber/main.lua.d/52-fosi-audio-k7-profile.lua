-- Fosi Audio K7 - Profile priority configuration
-- Sets the correct profile priority based on UAC mode

device_defaults = device_defaults or {}
device_defaults.profile_priorities = device_defaults.profile_priorities or {}

-- UAC 1.0 Mode: Prioritize profile with microphone input  
table.insert(device_defaults.profile_priorities, 1, {
  matches = {
    {
      { "device.name", "matches", "alsa_card.usb-Fosi_Audio_Fosi_Audio_K7*" },
      { "api.alsa.card.longname", "matches", "*full speed*" },
    },
  },
  priorities = {
    "output:iec958-stereo+input:analog-stereo",
    "output:analog-stereo+input:analog-stereo",
  }
})

-- UAC 2.0 Mode: Prioritize high-resolution output profile
table.insert(device_defaults.profile_priorities, 1, {
  matches = {
    {
      { "device.name", "matches", "alsa_card.usb-Fosi_Audio_Fosi_Audio_K7*" },
      { "api.alsa.card.longname", "matches", "*high speed*" },
    },
  },
  priorities = {
    "output:iec958-stereo",
  }
})
