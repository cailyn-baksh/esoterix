#!/bin/bash

# GUI Structure
# GUI screens are connected by functions which call each other using the below
# chain. Each function returns the dialog return codes it did not handle itself
# to its caller.
#
# Start
# |
# Select Action
# |__________
# |			|
# Install	Emulate
# 			|________________
#			|				|
#			Built-in Board	Custom Board
#			|				|____________
#			|				|			|
#			|				Load File	New Config
#			|				|			|
#			|				|			CPU
#			|				|			|
#			|				|			Memory
#			|				|			|
#			|				|			Confirm
#			|				|			|
#			|				|			Save Config
#			|_______________|___________|
#			|
#			Emulator Options

DIALOG_OPTS="--shadow --keep-tite --colors --cancel-label Back"

GUI=1

TARGET_MACHINE=

CUSTOM_TARGET_NAME=
CUSTOM_TARGET_CPU=
CUSTOM_TARGET_MEMORY=

main() {
	# handle options
	options=$(getopt -l "help,no-gui" -o "h" -- $@)
	eval set -- "$options"
	while true; do
		case $1 in
			-h|--help)
				print_help
				exit 0
				;;
			--no-gui)
				GUI=0
				;;
			--)
				shift
				break
				;;
		esac
		shift
	done


	if [ $GUI == 1 ]; then
		command -v >&- "dialog" || printf >&2 "dialog is required to use this script!\n"
		start_gui
	else
		echo "Not Implemented!"
	fi
}

print_help() {
# Help must use spaces instead of tabs so tab width doesn't affect display
cat << EOF
Usage $0 [options]
Install or start emulating esoterix. If no options are specified then a text
GUI is displayed to decide how to proceed.

Options:
  -h, --help        Display this help message
      --no-gui      Do not show the gui; instead infer actions from the command
                    line.
EOF
}

start_gui() {
	tput smcup
	exec 3>&1

	while true; do
		dialog $DIALOG_OPTS --extra-button --extra-label Cancel --ok-label "Begin" \
		--msgbox "\ZbWelcome to the Esoterix installer wizard!\ZB\
\n\nThis wizard will guide you through installating or emulating Esoterix. Press \ZbEsc\ZB at any time to quit." 0 0

		if [[ $? == 255 || $? == 3 ]]; then
			exit_gui
		fi

		gui_select_action
		local status=$?

		if [[ $status == 0 ]]; then
			:
		elif [[ $status == 1 ]]; then
			continue
		fi

		break
	done

	exit_gui
}

exit_gui() {
	exec 3>&-
	tput rmcup
	printf "$1\n"
	exit
}

gui_select_action() {
	while true; do
		local action
		action=$(dialog $DIALOG_OPTS --menu "Select an action" 0 0 3 \
							1 "Install onto an SD card" \
							2 "Emulate in QEMU" 2>&1 1>&3)
		local status=$?

		if [[ $status == 0 ]]; then
			# Success
			if [[ $action == 1 ]]; then
				# Install
				exit_gui "Not implemented!"
			elif [[ $action == 2  ]]; then
				# Emulate
				gui_select_board

				if [[ $? == 1 ]]; then
					continue
				fi
			fi
		elif [[ $status == 255 ]]; then
			# exit
			exit_gui
		fi

		break
	done

	return $status
}

gui_select_board() {
	while true; do
		local board
		board=$(dialog $DIALOG_OPTS --menu "Select a Board" 0 0 3 \
						1 "Raspberry Pi Zero" \
						2 "Raspberry Pi 1 A+" \
						3 "Raspberry Pi 2 B" \
						4 "Custom" 2>&1 1>&3)
		local status=$?

		if [[ $status == 0 ]]; then
			case $board in
				1)
					TARGET_MACHINE=raspi0
					;;
				2)
					TARGET_MACHINE=raspi1ap
					;;
				3)
					TARGET_MACHINE=raspi2b
					;;
				4)
					TARGET_MACHINE=versatilepb

					gui_load_custom_board_config
					if [[ $? == 1 ]]; then
						continue
					fi
					;;
			esac

			gui_emulator_options

			if [[ $? == 1 ]]; then
				continue
			fi
		fi
		break
	done

	return $status
}

gui_load_custom_board_config() {
	while true; do
		local filename
		filename=$(dialog $DIALOG_OPTS --title "Select Emulator Config File" --extra-button --extra-label "New Config" --fselect "" 0 0 2>&1 1>&3)
		local status=$?

		if [[ $status == 0 ]]; then
			. $filename  # load file

			gui_emulator_options

			if [[ $? == 1 ]]; then
				continue;
			fi
		elif [[ $status == 3 ]]; then
			gui_new_config

			if [[ $? == 1 ]]; then
				continue
			fi
		fi
		break
	done

	return $status
}

gui_new_config() {
	while true; do
		local name
		name=$(dialog $DIALOG_OPTS --inputbox "\ZbBoard Name" 0 0 "My Pi" 2>&1 1>&3)
		local status=$?

		if [[ $status == 0 ]]; then
			CUSTOM_TARGET_NAME=$name
			gui_set_cpu

			if [[ $? == 1 ]]; then
				continue
			fi
		fi

		break
	done

	return $status
}

gui_set_cpu() {
	while true; do
		local cpu
		cpu=$(dialog $DIALOG_OPTS --help-button --inputbox "\ZbCPU" 0 0 "cortex-a7" 2>&1 1>&3)
		local status=$?

		if [[ $status == 0 ]]; then
			CUSTOM_TARGET_CPU=$cpu

			gui_set_mem

			if [[ $? == 1 ]]; then
				continue
			fi
		elif [[ $status == 2 ]]; then
			# Help
			# TODO: improve this
			dialog $DIALOG_OPTS --no-shadow --keep-window --no-collapse --msgbox "$(qemu-system-arm -cpu help)" 0 0
			continue
		fi

		break
	done

	return $status
}

gui_set_mem() {
	while true; do
		local mem
		mem=$(dialog $DIALOG_OPTS --inputbox "\ZbMemory" 0 0 "512M" 2>&1 1>&3)
		local status=$?

		if [[ $status == 0 ]]; then
			CUSTOM_TARGET_MEM=$mem

			gui_confirm_config

			if [[ $? == 1 ]]; then
				continue
			fi
		fi

		break
	done

	return $status
}

gui_confirm_config() {
	while true; do
		dialog $DIALOG_OPTS --title "Is this correct?" --yesno "\Zu$CUSTOM_TARGET_NAME\ZU\n\ZbCPU:\ZB $CUSTOM_TARGET_CPU\n\ZbMEM:\ZB $CUSTOM_TARGET_MEM" 0 0
		local status=$?

		if [[ $status == 0 ]]; then
			gui_config_save

			if [[ $? == 1 ]]; then
				continue
			fi
		fi

		break
	done

	return $status
}

gui_config_save() {
	while true; do
		local filename
		filename=$(dialog $DIALOG_OPTS --title "Save Emulator Config File" --fselect "$(echo $CUSTOM_TARGET_NAME.cfg | tr -d ' ')" 0 0 2>&1 1>&3)
		local status=$?

		if [[ $status == 0 ]]; then
			dialog $DIALOG_OPTS --no-shadow --keep-window --begin 0 0 --sleep 2 --infobox "Saving to $(realpath $filename)" 0 0

			printf "CUSTOM_TARGET_NAME=\"$CUSTOM_TARGET_NAME\"\n" 1> $filename
			printf "CUSTOM_TARGET_CPU=\"$CUSTOM_TARGET_CPU\"\n" 1>> $filename
			printf "CUSTOM_TARGET_MEM=\"$CUSTOM_TARGET_MEM\"\n" 1>> $filename

			gui_emulator_options

			if [[ $? == 1 ]]; then
				continue;
			fi
		fi

		break
	done

	return $status
}

gui_emulator_options() {
	while true; do
		local msg
		if [[ -z $CUSTOM_TARGET_NAME ]]; then
			msg="\ZbMachine:\ZB $TARGET_MACHINE\n"
		else
			msg="\ZbMachine:\ZB $TARGET_MACHINE\n\ZbProfile:\ZB $CUSTOM_TARGET_NAME\n\ZbCPU:\ZB $CUSTOM_TARGET_CPU\n\ZbMEM:\ZB $CUSTOM_TARGET_MEM"
		fi

		dialog $DIALOG_OPTS --title "Emulator Options" --extra-button --extra-label "Advanced" --yesno "$msg" 0 0
		local status=$?

		break
	done

	return $status
}

main $@

