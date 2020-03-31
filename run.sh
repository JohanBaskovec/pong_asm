./build.sh

if [ $? -eq 0 ]; then
    ./pong
    echo "Exit with code" $?
    exit 0
else
    exit 1
fi

