#!/bin/bash
CURRENT_DIR="/opt/DeckShare"
set -o allexport
source $CURRENT_DIR/.env
set +o allexport


# Directory to monitor
MONITOR_DIR=$(python3 /opt/DeckShare/steampy/path.py)
echo "Monitor Directory: " $MONITOR_DIR

# File to save the state
STATE_FILE=$CURRENT_DIR"/monitor.state"

# Function to process a file
process_file() {
  echo "Processing file: $1"
  upload_file $1
}

upload_file() {

  # Check if the webhook URL was read correctly
  if [ -z "$webhook_url" ]; then
      echo "Webhook URL not found in environment"
      exit 1
  fi

  # File to be uploaded
  filename=$1

  echo "filename: $filename"
  echo "Webhook URL: $webhook_url"

  # Check if the file exists
  if [ ! -f "$filename" ]; then
      echo "File $filename does not exist"
      exit 1
  fi

  # Send the file using curl
  curl -F "content=Here is the latest screenshot" -F "file=@$filename" $webhook_url

  # Check the exit status of curl for success or failure
  if [ $? -eq 0 ]; then
      echo "Successfully uploaded $filename to Discord"
  else
      echo "Failed to upload $filename to Discord"
  fi
}

# Check if the state file exists and load the last processed file if available
if [ -f "$STATE_FILE" ]; then
  LAST_FILE=$(cat "$STATE_FILE")
else
  $(touch $STATE_FILE)
  LAST_FILE=$(cat "$STATE_FILE")
fi

# Monitor the directory for changes
while true; do
  for FILE_CHANGED in $(find "$MONITOR_DIR" -type f -newer "$STATE_FILE"); do
    # Check if the file is different from the last processed file
    if [ "$FILE_CHANGED" != "$LAST_FILE" ]; then
      process_file "$FILE_CHANGED"

      # Save the current state to the state file
      echo "$FILE_CHANGED" > "$STATE_FILE"
      LAST_FILE="$FILE_CHANGED"
    fi
  done

  # Sleep for a while before checking again (adjust as needed)
  sleep 5
done
