nasm -f elf64 -g -F dwarf -l pong.lst pong.asm


if [ $? -eq 0 ]; then
    clang -g -o pong pong.o `sdl2-config --cflags --libs`

    if [ $? -eq 0 ]; then
        chmod +x ./pong
        exit 0
    else
        exit 1
    fi
else
    exit 1
fi

