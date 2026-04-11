export def --wrapped BluetoothConnector [
    --toggle
    ...rest: string       # Captures all other flags and paths
] {
    if not $toggle {
        return (^BluetoothConnector ...$rest)
    }
    if (^BluetoothConnector --status ...$rest) == "Connected" {
        ^BluetoothConnector --disconnect ...$rest
    } else {
        ^BluetoothConnector --connect ...$rest
    }
}

# toggle airpods between the current device and another one
# the other device need to connect automatically to airpods whenever they are not connected to the current device
#
# REQUIREMENTS:
# 	1. spotify_player: cargo install spotify_player --locked
# 	2. BluetoothConnector: brew install bluetoothconnector
export def toggle_airpods_and_spotify [
	airpod_mac_address: string,
	current_device_name: string # current device name on Spotify
	other_device_name: string # other device name on Spotify
]: nothing -> string {
	if (which spotify_player | is-empty) {
		return "spotify_player not found"
	}
	if (which BluetoothConnector | is-empty) {
		return "BluetoothConnector not found"
	}

	let device_to_connect_to = if (BluetoothConnector --status $airpod_mac_address | str trim) == "Connected" {
		$other_device_name
	} else {
		$current_device_name
	}

	BluetoothConnector --toggle $airpod_mac_address

	spotify_player connect --name $device_to_connect_to | complete
	if $device_to_connect_to == $current_device_name {
		mut timeout_counter = 0
		while (BluetoothConnector --status $airpod_mac_address | str trim) != "Connected" {
			print --stderr "Waiting for airpods to connect..."
			sleep 1sec
			$timeout_counter += 1
			if $timeout_counter > 10 {
				return "Airpods not connected"
			}
		}
		sleep 1sec
	} else {
		sleep 5sec
	}

	spotify_player playback play | complete
	return $"Airpods toggled to ($device_to_connect_to)"
}
