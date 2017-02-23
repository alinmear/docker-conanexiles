#!/usr/bin/env bash

child=0

trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM
exit_handler()
{
	echo "Shut down signal received.."
	sleep 1
	kill $child
	exit
}


steamcmd_setup
exiles_server_update

    

# Install/update Conan Exiles from install.txt
echo "Installing/updating Conan Exiles.. (this might take a while, be patient)"
bash /steamcmd/steamcmd.sh +runscript /install.txt

#STEAMCMD_OUTPUT=$(bash /steamcmd/steamcmd.sh +runscript /install.txt | tee /dev/stdout)
#STEAMCMD_ERROR=$(echo $STEAMCMD_OUTPUT | grep -q 'Error')
#if [ ! -z "$STEAMCMD_ERROR" ]; then
#	echo "Exiting, steamcmd install or update failed: $STEAMCMD_ERROR"
#	exit
#fi

# Run the update check if it's not been run before
# if [ ! -f "/steamcmd/conan/build.id" ]; then
	# server_update_check
# else
	# OLD_BUILDID="$(cat /steamcmd/conan/build.id)"
	# STRING_SIZE=${#OLD_BUILDID}
	# if [ "$STRING_SIZE" -lt "6" ]; then
		# ./server_update_check
	# fi
# fi

# Set the working directory
# cd /steamcmd/conan

# Run the server
# echo "Starting Conan Exiles.."
# /steamcmd/conan/start ${CONAN_EXILES_SERVER_STARTUP_ARGUMENTS} -nosteamclient -game -server -log &

# child=$!
# wait "$child"
