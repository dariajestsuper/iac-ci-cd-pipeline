echo "Checking prerequisites."

prerequisites_met=true

if ! command -v docker > /dev/null 2>&1
then
    echo "[ERROR] Docker is not installed. Please install Docker to proceed."
    prerequisites_met=false
fi

if ! command -v compose > /dev/null 2>&1
then
    echo "[ERROR] Docker Compose is not installed. Please install Docker Compose to proceed."
    prerequisites_met=false
fi

if ! command -v tflocal > /dev/null 2>&1
then
    echo "[ERROR] tflocal is not installed. Please install tflocal (part of localstack) to proceed."
    prerequisites_met=false
fi

if [ "$prerequisites_met" = false ]; then
    echo "[ERROR] One or more prerequisites are not met. Please install the missing tools and try again."
    exit 1
else
    echo "[INFO] All prerequisites are met."
fi