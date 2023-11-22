#!/bin/bash
CURRENT_DIR="/opt/DeckShare"

# Load .env file
set -o allexport
source $CURRENT_DIR/.env
set +o allexport

# Validate required variables
# Check if the webhook URL was read correctly
if [ -z "$webhook_url" ]; then
    echo "Webhook URL not found in environment"
    exit 1
fi

# Directory to monitor
MONITOR_DIR=$(python3 /opt/DeckShare/steampy/path.py)
echo "Monitor Directory: " $MONITOR_DIR

# File to save the state
STATE_FILE=$CURRENT_DIR"/monitor.state"

# Function to process a file
process_file() {
  thumbnailSearch="thumbnail"
  # Check to see if this is a thumbnail
  if [[ "$1" == *"$thumbnailSearch"* ]]; then
    # Check to see if thumbnails are enabled
    if [[ "$thumbnails" == "1" ]]; then
      # If enabled, upload, otherwise skip
      upload_file $1
    fi
  else
    upload_file $1
  fi
}

upload_file() {
  # File to be uploaded
  filename=$1

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

  # Sleep for a while before checking again
  sleep 5
done
